//
//  MMTFeedQCell.m
//  MyMusicTaste
//
//  Created by 주영 이 on 13. 2. 17..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "DemoCell.h"

@implementation DemoCell

-(void)applyData:(id)data{
    [super applyData:data];
    NSDictionary *dict = data;
    NSString *color = [dict objectForKey:@"color"];
    if([color isEqualToString:@"orange"]){
        [self setBackgroundColor:[UIColor orangeColor]];
    }
    else if([color isEqualToString:@"orange"]){
        [self setBackgroundColor:[UIColor orangeColor]];
    }
    else if([color isEqualToString:@"blue"]){
        [self setBackgroundColor:[UIColor blueColor]];
    }
    else if([color isEqualToString:@"black"]){
        [self setBackgroundColor:[UIColor blackColor]];
    }
    else if([color isEqualToString:@"red"]){
        [self setBackgroundColor:[UIColor redColor]];
    }
    else if([color isEqualToString:@"white"]){
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    else if([color isEqualToString:@"gray"]){
        [self setBackgroundColor:[UIColor grayColor]];
    }
    else if([color isEqualToString:@"yellow"]){
        [self setBackgroundColor:[UIColor yellowColor]];
    }
    else if([color isEqualToString:@"purple"]){
        [self setBackgroundColor:[UIColor purpleColor]];
    }
    else if([color isEqualToString:@"green"]){
        [self setBackgroundColor:[UIColor greenColor]];
    }
    self.label.text = [NSString stringWithFormat:@"N:%@",[dict objectForKey:@"id"]];
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
}
+ (CGFloat)getHeightWithWidth:(CGFloat)width forData:(id)data{
    NSDictionary *dict = data;
    return [[dict objectForKey:@"height"] floatValue];
}


@end
