//
//  ItunesSearchProvider.m
//  MFMasonryView
//
//  Created by 주영 이 on 13. 5. 29..
//  Copyright (c) 2013년 uptown. All rights reserved.
//

#import "ItunesSearchProvider.h"
#import "AFJSONRequestOperation.h"
#import "NSString+URLENCODE.h"

@interface ItunesSearchProvider ()
@property (nonatomic, strong) NSString *query;
@end

@implementation ItunesSearchProvider
-(id)initWithParams:(id)params{
    if(self = [super initWithParams:params]){
        self.query = [params objectForKey:@"query"];;
    }
    return self;
}

- (void)filter:(NSString *)query{
    if([query length] != 0){
        self.query = query;
        [self reservedLoad];
    }
}

- (void)loadWithCallback:(MFDataProviderCallback)callback{
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&entity=software&limit=200",[self.query urlencode]]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        callback([JSON objectForKey:@"results"]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@",error);
        callback(nil);
    }];
    [operation start];
}

- (BOOL)canRefresh{
    return YES;
}
@end
