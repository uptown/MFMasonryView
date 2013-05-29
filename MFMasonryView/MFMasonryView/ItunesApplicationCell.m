//
//  ItunesApplicationCell.m
//  MFMasonryView
//
//  Created by 주영 이 on 13. 5. 29..
//  Copyright (c) 2013년 uptown. All rights reserved.
//

#import "ItunesApplicationCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ItunesApplicationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)applyData:(id)data{
    [super applyData:data];
    [self.applicationIcon setImageWithURL:[NSURL URLWithString:[data objectForKey:@"artworkUrl100"]]];
    self.nameLabel.text = [data objectForKey:@"trackCensoredName"];
    self.otherInfo.text = [NSString stringWithFormat:@"Version:%@\nPrice:%@\nRating:%@\nSeller:%@",[data objectForKey:@"version"],[data objectForKey:@"formattedPrice"],[data objectForKey:@"averageUserRating"],[data objectForKey:@"sellerName"]];
    self.description.text = [data objectForKey:@"description"];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.applicationIcon.frame = CGRectMake(0, 0, width, width);
    self.nameLabel.frame = CGRectMake(0, width + 5, width, 25);
    self.otherInfo.frame = CGRectMake(0, width + 30, width, 70);
    self.description.frame = CGRectMake(0, width + 100 + 5, width, height - width - 105);
}

+ (CGFloat)getHeightWithWidth:(CGFloat)width forData:(id)data{
    static UILabel *label;
    if(!label){
        label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:14.0f]];
    }
    label.text = [data objectForKey:@"description"];
    return [label textRectForBounds:CGRectMake(0, 0, width, CGFLOAT_MAX)
               limitedToNumberOfLines:0].size.height + width + 105;
    
}


@end
