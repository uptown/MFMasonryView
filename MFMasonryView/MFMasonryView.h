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
- (void)masonryView:(MFMasonryView *)masonryView didReceivedData:(id)data;
- (void)masonryView:(MFMasonryView *)masonryView didSelectCellAtIndex:(NSUInteger)index;

@end

@interface MFMasonryView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<MFMasonryViewDataSource> dataSource;
@property (nonatomic, weak) id<MFMasonryViewDelegate> delegate;
@property (nonatomic, assign) CGFloat widthSpacing;
@property (nonatomic, assign) CGFloat heightSpacing;
@property (nonatomic, assign) CGFloat firstColumnMargin;
@property (nonatomic, readonly) CGFloat itemWidth;
@property (nonatomic, readonly) CGFloat minHeight;
@property (nonatomic, strong) UIView *masonryTopView;
@property (nonatomic, strong) UIView *coverView;

- (MFMasonryViewCell *)cellForItemAtIndex:(NSInteger)position;
- (NSArray *)visibleCells;
- (NSArray *)visibleIndexes;
- (void)reloadData;
- (void)reloadDataAdded;
- (MFMasonryViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)receiveData:(id)data fromCell:(MFMasonryViewCell *)cell;

//- (MFMasonryViewCell *)cellAtIndex:(NSUInteger)index;

/*
 - (CGFloat)heightForCellAtIndex:(NSUInteger)index;
 - (CGFloat)cellWidth;
 - (NSInteger)numberOfCells;
 - (NSInteger)numberOfColumns;
 - (NSInteger)numberOfCellsInColumn:(NSInteger)column;
 */

@end
