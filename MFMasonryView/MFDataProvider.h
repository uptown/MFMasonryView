//
//  MFDataProvider.h
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 6..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//


@class MFDataProvider;
typedef enum {
    MFDataProviderInit,
    MFDataProviderLoading,
    MFDataProviderLoaded,
    MFDataProviderRefeshing,
    MFDataProviderGettingMore,
    MFDataProviderNotAvailable,
    MFDataProviderFailed
} MFDataProviderState;

typedef void (^MFDataProviderCallback)(id data);
@protocol MFDataProviderDelegate <NSObject>

@optional
- (void)dataProvider:(MFDataProvider *)provider changeState:(MFDataProviderState)toState from:(MFDataProviderState)fromState;

@end

@protocol MFDataProviderProtocol <NSObject>


@end

@interface MFDataProvider : NSObject{
@protected
    MFDataProviderState _currentState;
}
@property (nonatomic, readonly) MFDataProviderState state;
@property (nonatomic, weak) id<MFDataProviderDelegate> delegate;
@property (nonatomic, readonly) NSDate *lastUpdatedDate;
@property (nonatomic, strong) id params;

- (id)initWithParams:(id)params;

- (void)refresh;
- (void)forceRefresh;
- (void)load;
- (void)getMore;
- (BOOL)canGetMore;
- (BOOL)canRefresh;
- (void)reservedLoad;
- (void)setNotAvailable;
- (void)setFailed;

// Protected ...
- (void)getMoreWithCallback:(MFDataProviderCallback)callback;
- (void)loadWithCallback:(MFDataProviderCallback)callback;
- (BOOL)getMoreProcess:(id)data;
- (BOOL)refreshProcess:(id)data;
- (BOOL)loadProcess:(id)data;
- (void)filter:(id)filter;
@end
