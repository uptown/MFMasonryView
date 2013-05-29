//
//  MFMasonryViewCell.m
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 18..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFMasonryViewCell.h"
#import "MFMasonryView.h"
@implementation MFMasonryViewCell

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize selected = _selected;

- (void)dealloc {
    _reuseIdentifier = nil;
    _data = nil;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if (self) {
        _reuseIdentifier = reuseIdentifier ;
    }
    return self;
}

+ (MFMasonryViewCell *)getReusedCellFromMasonryView:(MFMasonryView *)masonryView withReusedentifier:(NSString*)reuseIdentifier{
    
    NSString *className = NSStringFromClass([self class]);
    
    MFMasonryViewCell *cell;
    if(masonryView)
        cell = [masonryView dequeueReusableCellWithReuseIdentifier:reuseIdentifier];
    if(cell == nil){
        
        NSString *nibName = [[NSBundle mainBundle] pathForResource:className ofType:@"nib"]? className : nil;
        if(!nibName){
            if(IS_IPHONE){
                NSString *iPhoneNibName = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_iPhone",className] ofType:@"nib"];
                if(iPhoneNibName){
                    nibName = [NSString stringWithFormat:@"%@_iPhone",className];
                }
            }
            else{
                NSString *iPadNibName = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_iPad",className] ofType:@"nib"];
                if(iPadNibName){
                    nibName = [NSString stringWithFormat:@"%@_iPad",className];
                }
            }
        }
        if(nibName){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:masonryView options:nil];
            
            for (id oneObject in nib) {
                if ([oneObject isKindOfClass:[MFMasonryViewCell class]]) {
                    cell = oneObject;
                    cell.reuseIdentifier = reuseIdentifier;
                    break;
                }
            }
        }
        if(cell == nil){
            cell = [[[self class] alloc] initWithReuseIdentifier:reuseIdentifier];
        }
    }
    return cell;
}

- (void)applyData:(id)data{
    _data = data;
}

+ (CGFloat)getHeightWithWidth:(CGFloat)width forData:(id)data{
    return width;
}


- (void)sendDataToMasonryView:(id)data{
    if([self.superview isKindOfClass:[MFMasonryView class]]){
        [(MFMasonryView*)self.superview receiveData:data fromCell:self];
    }
}

- (void)prepareForReuse{
}
@end
