//
//  MFQuiltBasedViewController.h
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 16..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFMasonryView.h"
#import "MFArrayProvider.h"

@interface MFMasonryBasedViewController : UIViewController<MFMasonryViewDataSource, MFMasonryViewDelegate, MFDataProviderDelegate>

@property (nonatomic, strong) MFArrayProvider *dataProvider;
@property (nonatomic, strong) IBOutlet MFMasonryView *masonryView;

- (id)initWithArrayProvider:(MFArrayProvider *)dataProvider;
@end
