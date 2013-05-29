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

@interface MFMasonryBasedViewControllerHelper : NSObject

- (id)initWithController:(MFMasonryBasedViewController *)controller;
- (void)refresh;
@end

@implementation MFMasonryBasedViewControllerHelper{
    __weak MFMasonryBasedViewController *controller_;
}


- (id)initWithController:(MFMasonryBasedViewController *)controller{
    if(self = [super init]){
        controller_ = controller;
    }
    return self;
}
- (void)refresh{
    [controller_.dataProvider refresh];
}

@end

@interface MFMasonryBasedViewController ()

@property (nonatomic, strong) ODRefreshControl *refreshControl;
@end

@implementation MFMasonryBasedViewController{
    MFMasonryBasedViewControllerHelper *observer_;
}


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
    observer_ = [[MFMasonryBasedViewControllerHelper alloc] initWithController:self];
    if([self.dataProvider canRefresh]){
        
        self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.masonryView];
        [self.refreshControl addTarget:observer_ action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    self.dataProvider.delegate = self;
    _masonryView.delegate = self;
    _masonryView.dataSource = self;
    [self.masonryView reloadData];
    
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self.refreshControl removeTarget:observer_ action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSTimeInterval passed = [[NSDate date] timeIntervalSinceDate:self.dataProvider.lastUpdatedDate];
    if(passed > 300){
        [self.dataProvider refresh];
    }
    else{
        [self.masonryView reloadData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)dataProvider:(MFDataProvider *)provider changeState:(MFDataProviderState)toState from:(MFDataProviderState)fromState{
    if(toState == MFDataProviderLoaded){
        if(fromState == MFDataProviderGettingMore){
            [self.masonryView reloadDataAdded];
        }
        else{
            [self.masonryView reloadData];
        }
        if(fromState == MFDataProviderRefeshing){
            [self.refreshControl endRefreshing];
        }
    }
}

- (void)setAvaliable:(BOOL)isAvailable{
    
}


- (void)scrollViewDidScroll: (UIScrollView*)scroll {
    if([self.dataProvider canGetMore] && scroll == self.masonryView){
        // UITableView only moves in one direction, y axis
        NSInteger currentOffset = scroll.contentOffset.y;
        NSInteger maximumOffset = MIN(scroll.contentSize.height - scroll.frame.size.height,[(MFMasonryView*)scroll minHeight] - scroll.frame.size.height);
        
        if (maximumOffset - currentOffset <= 320.0) {
            [self.dataProvider getMore];
        }
    }
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
