//
//  ItunesApplicationCell.h
//  MFMasonryView
//
//  Created by 주영 이 on 13. 5. 29..
//  Copyright (c) 2013년 uptown. All rights reserved.
//

#import "MFMasonryViewCell.h"

@interface ItunesApplicationCell : MFMasonryViewCell
@property (nonatomic, strong) IBOutlet UIImageView *applicationIcon;
@property (nonatomic, strong) IBOutlet UILabel *description;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *otherInfo;
@end
