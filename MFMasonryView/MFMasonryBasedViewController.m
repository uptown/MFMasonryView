//
//  MFQuiltBasedViewController.m
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 16..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFMasonryBasedViewController.h"
#import "MFMasonryViewCell.h"
#import "ODRefreshControl.h"
@interface MFMasonryBasedViewController ()

@end

@implementation MFMasonryBasedViewController


- (id)initWithArrayProvider:(MFArrayProvider *)dataProvider{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.dataProvider = dataProvider;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataProvider.delegate = self;
    [self.dataProvider load];
    _masonryView.delegate = self;
    _masonryView.dataSource = self;
    if([self.dataProvider canRefresh]){
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.masonryView];
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    }
    self.dataProvider.delegate = self;
    [self.dataProvider load];
    [self.masonryView reloadData];
	// Do any additional setup after loading the view.
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataProvider:(MFDataProvider *)provider changeState:(MFDataProviderState)toState from:(MFDataProviderState)fromState{
    if(toState == MFDataProviderLoaded)
        [self.masonryView reloadData];
}

- (NSUInteger)masonryViewNumberOfCells:(MFMasonryView *)masonryView{
    return [self.dataProvider count];
}
- (NSUInteger)masonryViewNumberOfColumns:(MFMasonryView *)masonryView{
    return 2;
}
- (MFMasonryViewCell *)masonryView:(MFMasonryView *)masonryView cellAtIndex:(NSUInteger)index{
    MFMasonryViewCell *cell = [masonryView dequeueReusableCellWithReuseIdentifier:nil];
    if (!cell) {
        cell = [[MFMasonryViewCell alloc] initWithReuseIdentifier:nil];
    }
    return cell;
}

- (CGFloat)masonryView:(MFMasonryView *)masonryView heightForCellAtIndex:(NSUInteger)index{
    return [MFMasonryViewCell getHeightWithWidth:masonryView.itemWidth forData:[self.dataProvider objectAtIndex:index]];
}
@end
