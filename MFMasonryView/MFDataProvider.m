//
//  MFDataProvider.m
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 6..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFDataProvider.h"
@interface MFDataProvider()
@property (nonatomic, assign) BOOL reservedLoadOn;
@property (nonatomic, strong) NSDate *lastUpdatedDate;
@end
@implementation MFDataProvider

@synthesize state = _currentState;

- (id)init{
    self = [super init];
    if(self){
        _currentState = MFDataProviderInit;
    }
    return self;
}

- (id)initWithParams:(id)params{
    if(self = [self init]){
        self.params = params;
    }
    return self;
}
- (void)refresh{
    if(self.canRefresh){
        [self forceRefresh];
    }
}
- (void)forceRefresh{
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
            self.lastUpdatedDate = [NSDate date];
            
        }
        else{
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderNotAvailable from:_currentState];
            _currentState  = MFDataProviderNotAvailable;
        }
    }];
}

- (void)setNotAvailable{
    BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
    if (changeCallbackExists)
        [_delegate dataProvider:self changeState:MFDataProviderNotAvailable from:_currentState];
    _currentState  = MFDataProviderNotAvailable;
}


- (void)setFailed{
    BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
    if (changeCallbackExists)
        [_delegate dataProvider:self changeState:MFDataProviderFailed from:_currentState];
    _currentState  = MFDataProviderFailed;
}
- (void)load{
    BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
    if (changeCallbackExists)
        [_delegate dataProvider:self changeState:MFDataProviderLoading from:_currentState];
    _currentState = MFDataProviderLoading;
    
    [self loadWithCallback:^(id data) {
        BOOL changeCallbackExists = [_delegate respondsToSelector:@selector(dataProvider:changeState:from:)];
        
        if(self.reservedLoadOn){
            self.reservedLoadOn = NO;
            _currentState  = MFDataProviderLoaded;
            [self load];
            return;
        }
        BOOL isSuccess = [self loadProcess:data];
        
        if(isSuccess){
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderLoaded from:_currentState];
            _currentState  = MFDataProviderLoaded;
            self.lastUpdatedDate = [NSDate date];
            
            
        }
        else{
            
            if (changeCallbackExists)
                [_delegate dataProvider:self changeState:MFDataProviderNotAvailable from:_currentState];
            _currentState  = MFDataProviderNotAvailable;
        }
    }];
}

- (void)getMore{
    if(self.state == MFDataProviderLoaded){
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
}
- (void)reservedLoad{
    if(_currentState == MFDataProviderLoaded || _currentState == MFDataProviderInit){
        [self load];
    }
    else{
        self.reservedLoadOn = YES;
    }
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
    return [self loadProcess:data];
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
- (void)filter:(id)filter{
}

- (id)params{
    if(_params == nil){
        _params = [NSMutableDictionary dictionary];
    }
    return _params;
}
@end
