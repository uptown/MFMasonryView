//
//  MFViewController.m
//  MFMasonryView
//
//  Created by 주영 이 on 13. 2. 19..
//  Copyright (c) 2013년 uptown. All rights reserved.
//

#import "MFViewController.h"
#import "DemoCell.h"

@interface MFViewController ()

@end

@implementation MFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.dataProvider = [[MFArrayProvider alloc] initWithContentsOfFile:@"DemoData"];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MFMasonryViewCell *)masonryView:(MFMasonryView *)masonryView cellAtIndex:(NSUInteger)index{
    MFMasonryViewCell *cell = [DemoCell getReusedCellFromQuiltView:masonryView withReusedentifier:@"demo"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.dataProvider objectAtIndex:index]];
    [dict setObject:[NSNumber numberWithInt:index] forKey:@"id"];
    [cell applyData:dict];
    return cell;
}

- (CGFloat)masonryView:(MFMasonryView *)masonryView heightForCellAtIndex:(NSUInteger)index{
    return [DemoCell getHeightWithWidth:masonryView.itemWidth forData:[self.dataProvider objectAtIndex:index]];
}
- (NSUInteger)masonryViewNumberOfColumns:(MFMasonryView *)masonryView{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
    } else {
        return 2;
    }
}
@end
