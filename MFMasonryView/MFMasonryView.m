//
//  MFMasonryView.m
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 18..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFMasonryView.h"
#import "MFMasonryViewCell.h"
#import <QuartzCore/QuartzCore.h>
@interface MFMasonryView (){
    NSMutableArray *_cellHeightsAtIndex;
    NSMutableArray *_cellOriginYAtIndex;
    NSMutableArray *_cellColumnAtIndex;
    NSMutableArray *_visibleCells;
    
    NSUInteger _numberOfColumns;
    CGFloat _itemWidth;
    NSUInteger _numberOfCells;
    BOOL _visibleCellsCahceIsValid;
    BOOL _rotationActive;
}

- (void)_recalculateWithAnimation:(BOOL)animated;
- (CGRect)_rectOfCellAtIndex:(NSUInteger)index;
- (void)_relayoutVisibleCells:(BOOL)animated;
- (void)_loadRequiredCells;
- (void)_commonInit;

@end
@implementation MFMasonryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}


- (void)awakeFromNib{
    [super awakeFromNib];
    [self _commonInit];
}
- (void)_commonInit{
    _cellHeightsAtIndex = [NSMutableArray array];
    _cellOriginYAtIndex = [NSMutableArray array];
    _cellColumnAtIndex = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedWillRotateNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)reloadData{
    _numberOfCells = [self.dataSource masonryViewNumberOfCells:self];
    _numberOfColumns = [self.delegate masonryViewNumberOfColumns:self];
    [self _recalculateWithAnimation:NO];
    [self setNeedsLayout];
}

- (MFMasonryViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier{
    return nil;
}

- (void)_recalculateWithAnimation:(BOOL)animated{
    _itemWidth = (self.bounds.size.width - ((_numberOfColumns + 1) * self.widthSpacing)) / _numberOfColumns;
    [_cellHeightsAtIndex removeAllObjects];
    [_cellOriginYAtIndex removeAllObjects];
    [_cellColumnAtIndex removeAllObjects];
    float *tailsOfColumns = malloc(sizeof(float)* _numberOfColumns);
    NSUInteger currentColumn = 0;
    
    for (NSUInteger i = 0 ; i < _numberOfColumns ; i ++){
        tailsOfColumns[i] = 0;
    }
    
    for(NSUInteger i = 0; i < _numberOfCells ; i ++){
        CGFloat heightAtIndex = [self.delegate masonryView:self heightForCellAtIndex:i];
        [_cellHeightsAtIndex addObject:[NSNumber numberWithFloat:heightAtIndex]];
        tailsOfColumns[currentColumn] += _heightSpacing;
        
        [_cellOriginYAtIndex addObject:[NSNumber numberWithFloat:(tailsOfColumns[currentColumn])]];
        tailsOfColumns[currentColumn] += heightAtIndex;
        
        [_cellColumnAtIndex addObject:[NSNumber numberWithInt:currentColumn]];
        
        CGFloat minHeight = CGFLOAT_MAX;
        for (NSUInteger i = 0 ; i < _numberOfColumns ; i ++){
            if(minHeight > tailsOfColumns[i]){
                minHeight = tailsOfColumns[i];
                currentColumn = i;
            }
        }
        
    }
    CGFloat maxHeight = tailsOfColumns[0];
    for (NSUInteger i = 1 ; i < _numberOfColumns ; i ++){
        if(maxHeight < tailsOfColumns[i]){
            maxHeight = tailsOfColumns[i];
        }
    }
    CGSize contentSize = CGSizeMake(self.bounds.size.width, maxHeight);
    
    BOOL shouldUpdateScrollviewContentSize = !CGSizeEqualToSize(self.contentSize, contentSize);
    
    if (shouldUpdateScrollviewContentSize)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 self.contentSize = contentSize;
                             }
                             completion:nil];
        }
        else
        {
            self.contentSize = contentSize;
        }
    }
    
    free(tailsOfColumns);
}

- (void)_relayoutVisibleCells:(BOOL)animated{
    void (^layoutBlock)(void) = ^{
        BOOL needsSetCacheInvalid = NO;
        for (MFMasonryViewCell *view in [self visibleCells])
        {
            CGRect newFrame = [self _rectOfCellAtIndex:view.index];
            if(self.contentOffset.y - (newFrame.origin.y + newFrame.size.height) > 0 ||
               (self.contentOffset.y + self.bounds.size.height < newFrame.origin.y)){
                [view removeFromSuperview];
                needsSetCacheInvalid = YES;
            }
            else{
                if (!CGRectEqualToRect(newFrame, view.frame))
                {
                    view.frame = newFrame;
                }
            }
        }
        if(needsSetCacheInvalid){
            _visibleCellsCahceIsValid = NO;
            _visibleCells = nil;
        }
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             layoutBlock();
                         }
                         completion:nil
         ];
    }
    else
    {
        layoutBlock();
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if(_rotationActive){
        _rotationActive = NO;
        _numberOfColumns = [self.delegate masonryViewNumberOfColumns:self];
        [self _recalculateWithAnimation:NO];
        for (MFMasonryViewCell *view in [self visibleCells])
        {
            CGRect newFrame = [self _rectOfCellAtIndex:view.index];
            if (!CGRectEqualToRect(newFrame, view.frame))
            {
                view.frame = newFrame;
            }
        }
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:@"rotationAnimation"];
        
        [self applyWithoutAnimation:^{
            [self _relayoutVisibleCells:NO];
        }];
        
    }
    else{
        [self _relayoutVisibleCells:YES];
    }
    [self _loadRequiredCells];
    
    
}
- (CGRect)_rectOfCellAtIndex:(NSUInteger)index{
    CGFloat originY = [[_cellOriginYAtIndex objectAtIndex:index] floatValue];
    CGFloat height = [[_cellHeightsAtIndex objectAtIndex:index] floatValue];
    NSInteger column = [[_cellColumnAtIndex objectAtIndex:index] integerValue];
    CGFloat originX = (column - 1) * _widthSpacing + column * _itemWidth;
    return CGRectMake(originX, originY, _itemWidth, height);
}


- (MFMasonryViewCell *)cellForItemAtIndex:(NSInteger)position
{
    MFMasonryViewCell *view = nil;
    
    for (MFMasonryViewCell *v in [self visibleCells])
    {
        if (v.index == position)
        {
            view = v;
            break;
        }
    }
    
    return view;
}

- (void)_loadRequiredCells{
    for(NSUInteger i = 0; i < _numberOfCells ; i ++){
        CGRect frameOfIndex = [self _rectOfCellAtIndex:i];
        if(![self cellForItemAtIndex:i]){
            if((self.contentOffset.y <= (frameOfIndex.origin.y + frameOfIndex.size.height)
                && (self.contentOffset.y + self.bounds.size.height ) >= (frameOfIndex.origin.y))){
                   MFMasonryViewCell *cell = [self.dataSource masonryView:self cellAtIndex:i];
                   cell.index = i;
                   cell.frame = frameOfIndex;
                   [self addSubview:cell];
            }
        }
    }
    _visibleCellsCahceIsValid = NO;
    _visibleCells = nil;
}

- (NSArray *)visibleCells
{
    NSArray *subviews = nil;
    
    if (_visibleCellsCahceIsValid)
    {
        subviews = [_visibleCells copy];
    }
    else
    {
        @synchronized(self)
        {
            NSMutableArray *itemSubViews = [NSMutableArray array];
            
            for (UIView * v in [self subviews])
            {
                if ([v isKindOfClass:[MFMasonryViewCell class]])
                {
                    [itemSubViews addObject:v];
                }
            }
            
            subviews = itemSubViews;
            
            _visibleCells = [subviews copy];
            _visibleCellsCahceIsValid = YES;
        }
    }
    
    return subviews;
}


- (void)receivedWillRotateNotification:(NSNotification *)notification
{
    _rotationActive = YES;
}

- (void)applyWithoutAnimation:(void (^)(void))animations
{
    if (animations)
    {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        animations();
        [CATransaction commit];
    }
}

- (CGFloat) itemWidth{
    return _itemWidth;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}
@end
