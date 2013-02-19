//
//  MFTable.m
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 6..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFArrayProvider.h"

@implementation MFArrayProvider

- (id)objectAtIndex:(NSUInteger)index{
    if ([self count] > index)
        return [_defaultStorage objectAtIndex:index];
    return nil;
}
- (NSUInteger)count{
    return [_defaultStorage count];
}
- (id)initWithArray:(NSArray *)array{
    self = [super init];
    if(self){
        _defaultStorage = [NSMutableArray arrayWithArray:array];
    }
    return self;
}

- (id)init{
    self = [super init];
    if(self){
        _defaultStorage = [NSMutableArray array];
    }
    return self;
}
- (id)initWithContentsOfFile:(NSString *)file{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
    NSArray *data = [NSArray arrayWithContentsOfFile:path];
    
    return[self initWithArray:data];
}
- (void)dealloc{
    _defaultStorage = nil;
}

- (BOOL)getMoreProcess:(id)data{
    [_defaultStorage addObjectsFromArray:data];
    return YES;
}
- (BOOL)refreshProcess:(id)data{
    [_defaultStorage removeAllObjects];
    [_defaultStorage addObjectsFromArray:data];
    return YES;
}
- (BOOL)loadProcess:(id)data{
    [_defaultStorage removeAllObjects];
    [_defaultStorage addObjectsFromArray:data];
    return YES;
}

- (void)getMoreWithCallback:(MFDataProviderCallback)callback{
    callback(nil);
}
- (void)loadWithCallback:(MFDataProviderCallback)callback{
    callback([NSArray arrayWithArray:_defaultStorage]);
}
@end
