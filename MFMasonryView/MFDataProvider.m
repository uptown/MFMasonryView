//
//  MFDataProvider.m
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 6..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFDataProvider.h"
@interface MFDataProvider()
@end
@implementation MFDataProvider

@synthesize state = _currentState;
- (void)refresh{
    BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
    if (changeCallbackExists)
        [_delegate dataProvider:self changeState:MFDataProviderRefeshing from:_currentState];
    _currentState = MFDataProviderRefeshing;
    
    [self loadWithCallback:^(id data) {
        BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
        
        BOOL isSuccess = [self refreshProcess:data];
        
        if(isSuccess){
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderLoaded from:_currentState];
            _currentState  = MFDataProviderLoaded;
            
        }
        else{
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderNotAvailable from:_currentState];
            _currentState  = MFDataProviderNotAvailable;
        }
    }];
}
- (void)load{
    BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
    if (changeCallbackExists)
        [_delegate dataProvider:self changeState:MFDataProviderLoading from:_currentState];
    _currentState = MFDataProviderLoading;
    
    [self loadWithCallback:^(id data) {
        BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
        
        BOOL isSuccess = [self loadProcess:data];
        
        if(isSuccess){
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderLoaded from:_currentState];
            _currentState  = MFDataProviderLoaded;
            
        }
        else{
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderNotAvailable from:_currentState];
            _currentState  = MFDataProviderNotAvailable;
        }
    }];
}

- (void)getMore{
    BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
    if (changeCallbackExists)
        [_delegate dataProvider:self changeState:MFDataProviderGettingMore from:_currentState];
    _currentState = MFDataProviderGettingMore;
    
    [self getMoreWithCallback:^(id data) {
        BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
        
        BOOL isSuccess = [self getMoreProcess:data];
        
        if(isSuccess){
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderLoaded from:_currentState];
            _currentState  = MFDataProviderLoaded;
            
        }
        else{
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderNotAvailable from:_currentState];
            _currentState  = MFDataProviderNotAvailable;
        }
    }];
    
}

- (BOOL)canGetMore{
    return NO;
}
- (BOOL)canRefresh{
    return NO;
}
- (BOOL)getMoreProcess:(id)data{
    return YES;
}
- (BOOL)refreshProcess:(id)data{
    return YES;
}
- (BOOL)loadProcess:(id)data{
    return YES;
}
- (void)getMoreWithCallback:(MFDataProviderCallback)callback{
    callback(nil);
}
- (void)loadWithCallback:(MFDataProviderCallback)callback{
    callback(nil);
}
@end
