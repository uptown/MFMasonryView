//
//  MFMasonryView.h
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 18..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import <UIKit/UIKit.h>
/* TODO : dequeueReusableCellWithReuseIdentifier */
@class MFMasonryViewCell;
@class MFMasonryView;

@protocol MFMasonryViewDataSource <NSObject>

- (NSUInteger)masonryViewNumberOfCells:(MFMasonryView *)masonryView;
- (MFMasonryViewCell *)masonryView:(MFMasonryView *)masonryView cellAtIndex:(NSUInteger)index;

@end

@protocol MFMasonryViewDelegate <UIScrollViewDelegate>

- (CGFloat)masonryView:(MFMasonryView *)masonryView heightForCellAtIndex:(NSUInteger)index;
- (NSUInteger)masonryViewNumberOfColumns:(MFMasonryView *)masonryView;
@optional


- (void)masonryView:(MFMasonryView *)masonryView didSelectCellAtIndex:(NSUInteger)index;


@end

@interface MFMasonryView : UIScrollView 

@property (nonatomic, weak) id<MFMasonryViewDataSource> dataSource;
@property (nonatomic, weak) id<MFMasonryViewDelegate> delegate;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) CGFloat widthSpacing;
@property (nonatomic, assign) CGFloat heightSpacing;
@property (nonatomic, readonly) CGFloat itemWidth;


- (MFMasonryViewCell *)cellForItemAtIndex:(NSInteger)position;
- (NSArray *)visibleCells;
- (void)reloadData;
- (MFMasonryViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier;


@end
