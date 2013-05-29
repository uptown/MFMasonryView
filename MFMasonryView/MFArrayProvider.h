//
//  MFTable.h
//  M2TFramework
//
//  Created by 주영 이 on 13. 2. 6..
//  Copyright (c) 2013년 JJS Media. All rights reserved.
//

#import "MFDataProvider.h"


@interface MFArrayProvider : MFDataProvider{
@protected
    NSMutableArray *_defaultStorage;
}

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (id)initWithArray:(NSArray *)array;
- (id)initWithContentsOfFile:(NSString *)file;
@end
