//
//  MFMasonryViewCell.h
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 18..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MFMasonryView;
@interface MFMasonryViewCell : UIView{
@protected
    id _data;
}

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NSUInteger index;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

+ (MFMasonryViewCell *)getReusedCellFromMasonryView:(MFMasonryView *)quiltView withReusedentifier:(NSString*)reuseIdentifier;
- (void)applyData:(id)data;
+ (CGFloat)getHeightWithWidth:(CGFloat)width forData:(id)data;

- (void)sendDataToMasonryView:(id)data;
- (void)prepareForReuse;
@end
