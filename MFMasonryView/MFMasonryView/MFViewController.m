//
//  MFViewController.m
//  MFMasonryView
//
//  Created by 주영 이 on 13. 2. 19..
//  Copyright (c) 2013년 uptown. All rights reserved.
//

#import "MFViewController.h"
//#import "DemoCell.h"
#import "ItunesApplicationCell.h"
#import "ItunesSearchProvider.h"

@implementation MFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.dataProvider = [[ItunesSearchProvider alloc] init];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (MFMasonryViewCell *)masonryView:(MFMasonryView *)masonryView cellAtIndex:(NSUInteger)index{
    MFMasonryViewCell *cell = [ItunesApplicationCell getReusedCellFromMasonryView:masonryView withReusedentifier:@"demo"];
    [cell applyData:[self.dataProvider objectAtIndex:index]];
    return cell;
}

- (CGFloat)masonryView:(MFMasonryView *)masonryView heightForCellAtIndex:(NSUInteger)index{
    return [ItunesApplicationCell getHeightWithWidth:masonryView.itemWidth forData:[self.dataProvider objectAtIndex:index]];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.dataProvider filter:searchText];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}
- (NSUInteger)masonryViewNumberOfColumns:(MFMasonryView *)masonryView{
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)){
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
            || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            return 7;
        } else {
            return 5;
        }
    }
    else{
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
            || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            return 3;
        } else {
            return 2;
        }
    }
}
@end
