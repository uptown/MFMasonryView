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
    NSMutableArray *_visibleIndexes;
    NSMutableSet *_reusableCells;
    
    NSMutableDictionary *_cachedData;
    
    UITapGestureRecognizer *_tapGesture;
    NSUInteger _numberOfColumns;
    CGFloat _itemWidth;
    CGFloat _minHeight;
    NSUInteger _numberOfCells;
    BOOL _visibleCellsCahceIsValid;
    BOOL _rotationActive;
    CGFloat _adjustY;
}
- (void)_recalculateWithAnimation:(BOOL)animated;
- (CGRect)_rectOfCellAtIndex:(NSUInteger)index;
- (void)_relayoutVisibleCells:(BOOL)animated;
- (void)_loadRequiredCells;
- (void)_commonInit;
- (NSInteger)_itemPositionFromLocation:(CGPoint)point;
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
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
    _tapGesture.delegate = self;
    _tapGesture.numberOfTapsRequired = 1;
    _tapGesture.numberOfTouchesRequired = 1;
    _tapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_tapGesture];
    _firstColumnMargin = 0.0f;
    _cellHeightsAtIndex = [NSMutableArray array];
    _cellOriginYAtIndex = [NSMutableArray array];
    _cellColumnAtIndex = [NSMutableArray array];
    _reusableCells = [NSMutableSet set];
    _cachedData = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedWillRotateNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)reloadData{
    _numberOfCells = [self.dataSource masonryViewNumberOfCells:self];
    _numberOfColumns = [self.delegate masonryViewNumberOfColumns:self];
    _cachedData = [NSMutableDictionary dictionary];
    [self _recalculateWithAnimation:NO];
    
    for (MFMasonryViewCell *view in [self visibleCells])
    {
        [view removeFromSuperview];
    }
    _visibleCellsCahceIsValid = NO;
    [self setNeedsLayout];
}

- (void)reloadDataAdded{
    _numberOfCells = [self.dataSource masonryViewNumberOfCells:self];
    _numberOfColumns = [self.delegate masonryViewNumberOfColumns:self];
    _cachedData = [NSMutableDictionary dictionary];
    [self _recalculateWithAnimation:NO];
    
    for (MFMasonryViewCell *view in [self visibleCells])
    {
        CGRect frameOfIndex = [self _rectOfCellAtIndex:view.index];
        if((self.contentOffset.y > (frameOfIndex.origin.y + frameOfIndex.size.height )
            || (self.contentOffset.y + self.bounds.size.height ) < (frameOfIndex.origin.y ))){
            [view removeFromSuperview];
        }
    }
    _visibleCellsCahceIsValid = NO;
    [self setNeedsLayout];
    
}

- (MFMasonryViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier{
    MFMasonryViewCell *cell = nil;
    
    for (MFMasonryViewCell *reusableCell in [_reusableCells allObjects])
    {
        if ([reusableCell.reuseIdentifier isEqualToString:reuseIdentifier])
        {
            cell = reusableCell;
            break;
        }
    }
    
    if (cell)
    {
        [_reusableCells removeObject:cell];
    }
    
    return cell;
}
- (void)_recalculateWithAnimation:(BOOL)animated{
    _itemWidth = (self.bounds.size.width - ((_numberOfColumns + 1) * self.widthSpacing)) / _numberOfColumns;
    CGFloat maxHeight;
    NSDictionary *cached = [_cachedData objectForKey:[NSNumber numberWithInt:[[UIDevice currentDevice] orientation]]];
    if(cached){
        _cellColumnAtIndex = [[NSMutableArray arrayWithArray:[cached objectForKey:@"_cellColumnAtIndex"]] copy];
        _cellOriginYAtIndex = [[NSMutableArray arrayWithArray:[cached objectForKey:@"_cellOriginYAtIndex"]] copy];
        _cellColumnAtIndex = [[NSMutableArray arrayWithArray:[cached objectForKey:@"_cellColumnAtIndex"]] copy];
        maxHeight = [[cached objectForKey:@"maxHeight"] floatValue];
        _minHeight = [[cached objectForKey:@"minHeight"] floatValue];
    }
    else{
        NSMutableArray *cellHeightsAtIndex = [NSMutableArray array];
        NSMutableArray *cellOriginYAtIndex = [NSMutableArray array];
        NSMutableArray *cellColumnAtIndex = [NSMutableArray array];
        CGFloat *tailsOfColumns = malloc(sizeof(float)* _numberOfColumns);
        NSUInteger currentColumn = 0;
        
        tailsOfColumns[0] = _firstColumnMargin + _adjustY;
        for (NSUInteger i = 1 ; i < _numberOfColumns ; i ++){
            tailsOfColumns[i] = _adjustY;
        }
        
        CGFloat minHeight = CGFLOAT_MAX;
        for(NSUInteger i = 0; i < _numberOfCells ; i ++){
            CGFloat heightAtIndex = [self.delegate masonryView:self heightForCellAtIndex:i];
            [cellHeightsAtIndex addObject:[NSNumber numberWithFloat:heightAtIndex]];
            tailsOfColumns[currentColumn] += _heightSpacing;
            
            [cellOriginYAtIndex addObject:[NSNumber numberWithFloat:(tailsOfColumns[currentColumn])]];
            tailsOfColumns[currentColumn] += heightAtIndex;
            
            [cellColumnAtIndex addObject:[NSNumber numberWithInt:currentColumn]];
            minHeight = CGFLOAT_MAX;
            for (NSUInteger i = 0 ; i < _numberOfColumns ; i ++){
                if(tailsOfColumns[i] < minHeight){
                    minHeight = tailsOfColumns[i];
                    currentColumn = i;
                }
            }
            
        }
        minHeight = CGFLOAT_MAX;
        maxHeight = tailsOfColumns[0];
        for (NSUInteger i = 1 ; i < _numberOfColumns ; i ++){
            if(maxHeight < tailsOfColumns[i]){
                maxHeight = tailsOfColumns[i];
            }
            if(minHeight > tailsOfColumns[i]){
                minHeight = tailsOfColumns[i];
            }
        }
        
        _minHeight = minHeight;
        _cellHeightsAtIndex = cellHeightsAtIndex;
        _cellOriginYAtIndex = cellOriginYAtIndex;
        _cellColumnAtIndex = cellColumnAtIndex;
        [_cachedData setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                [_cellColumnAtIndex copy], @"_cellColumnAtIndex",
                                [_cellOriginYAtIndex copy], @"_cellOriginYAtIndex",
                                [_cellColumnAtIndex copy], @"_cellColumnAtIndex",
                                [NSNumber numberWithFloat:maxHeight], @"maxHeight",
                                [NSNumber numberWithFloat:_minHeight], @"minHeight",
                                nil] forKey:[NSNumber numberWithInt:[[UIDevice currentDevice] orientation]]];
        free(tailsOfColumns);
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
    
}
- (void)_relayoutVisibleCells:(BOOL)animated{
    void (^layoutBlock)(void) = ^{
        BOOL needsSetCacheInvalid = NO;
        for (MFMasonryViewCell *view in [self visibleCells])
        {
            if([_cellColumnAtIndex count] <= view.index){
                self.contentOffset = CGPointMake(0, 0);
                [self reloadData];
                return;
            }
            CGRect newFrame = [self _rectOfCellAtIndex:view.index];
            if(self.contentOffset.y - (newFrame.origin.y + newFrame.size.height) > 0 ||
               (self.contentOffset.y + self.bounds.size.height < newFrame.origin.y)){
                [view removeFromSuperview];
                [view prepareForReuse];
                [_reusableCells addObject:view];
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
        if([_visibleIndexes indexOfObject:_int(i)] != NSNotFound){
            continue;
        }
        CGRect frameOfIndex = [self _rectOfCellAtIndex:i];
        if(![self cellForItemAtIndex:i]){
            if((self.contentOffset.y <= (frameOfIndex.origin.y + frameOfIndex.size.height )
                && (self.contentOffset.y + self.bounds.size.height ) >= (frameOfIndex.origin.y ))){
                MFMasonryViewCell *cell = [self.dataSource masonryView:self cellAtIndex:i];
                cell.index = i;
                cell.frame = frameOfIndex;
                cell.alpha = 0.0;
                [self insertSubview:cell atIndex:0];
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 1.0;
                }];
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
            NSMutableArray *indexes = [NSMutableArray array];
            NSMutableArray *itemSubViews = [NSMutableArray array];
            
            for (MFMasonryViewCell * v in [self subviews])
            {
                if ([v isKindOfClass:[MFMasonryViewCell class]])
                {
                    [itemSubViews addObject:v];
                    [indexes addObject:_int(v.index)];
                }
            }NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
            [indexes sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            
            subviews = itemSubViews;
            _visibleIndexes = [indexes copy];
            _visibleCells = [subviews copy];
            _visibleCellsCahceIsValid = YES;
        }
    }
    
    return subviews;
}
- (NSArray *)visibleIndexes{
    if(_visibleCellsCahceIsValid){
        
        return [_visibleIndexes copy];
    }
    else{
        [self visibleCells];
        return [_visibleIndexes copy];
    }
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

- (CGFloat)itemWidth{
    return _itemWidth;
}

- (CGFloat)minHeight{
    return _minHeight;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}


- (void)receiveData:(id)data fromCell:(MFMasonryViewCell *)cell{
    if([self.delegate respondsToSelector:@selector(masonryView:didReceivedData:)]){
        [(id<MFMasonryViewDelegate>)self.delegate masonryView:self didReceivedData:data];
    }
}

- (void)setMasonryTopView:(UIView *)masonryTopView{
    _masonryTopView = masonryTopView;
    _adjustY = _masonryTopView.frame.size.height;
    CGRect frame = _masonryTopView.frame;
    frame.origin = CGPointMake(0, -self.contentInset.top + self.scrollIndicatorInsets.top);
    frame.size.width = self.frame.size.width;
    _masonryTopView.frame = frame;
    [self addSubview:_masonryTopView];
    [self reloadData];
}

- (NSInteger)_itemPositionFromLocation:(CGPoint)point{
    for (MFMasonryViewCell *view in self.visibleCells){
        if(CGRectContainsPoint(view.frame,point))
            return view.index;
    }
    return -1;
}



- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture
{
    CGPoint locationTouch = [_tapGesture locationInView:self];
    NSInteger position = [self _itemPositionFromLocation:locationTouch];
    
    if (position >= 0)
    {
        if([self.delegate respondsToSelector:@selector(masonryView:didSelectCellAtIndex:)])
        {
            [self.delegate masonryView:self didSelectCellAtIndex:position];
        }
    }
}


- (void)setCoverView:(UIView *)coverView{
    if(_coverView){
        [_coverView removeFromSuperview];
    }
    _coverView = coverView;
    //    CGRect frame = _coverView.frame;
    if(self.masonryTopView)
        [self insertSubview:_coverView belowSubview:self.masonryTopView];
    else{
        [self addSubview:_coverView];
    }
    
    
}


@end
