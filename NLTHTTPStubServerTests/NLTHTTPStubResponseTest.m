//
//  NLTHTTPStubResponseTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubResponseTest.h"
#import "NLTHTTPStubResponse.h"

@implementation NLTHTTPStubResponseTest

- (void)testResponseWith {
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    response.statusCode = 200;
    response.path = @"/index";
    response.data = [NSData data];
    response.shouldTimeout = YES;
    response.httpHeaders = [NSDictionary dictionaryWithObject:@"text/html; charset=UTF-8" forKey:@"Content-Type"];
    GHAssertEqualStrings(@"/index", response.path, @"pathちがう");
    GHAssertEquals(200, response.statusCode, @"ステータスコード違う");
    GHAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
    GHAssertNotNil(response.httpHeaders, @"httpHeadersが存在しない");
    GHAssertNotNil([response.httpHeaders objectForKey:@"Content-Type"], @"Content-Typeが存在しない");
    GHAssertEqualObjects(@"text/html; charset=UTF-8", [response.httpHeaders objectForKey:@"Content-Type"], @"Content-Type違う");
}

- (void)testURICheckBlock {
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    [response URICheckWithBlock:^BOOL(NSURL *URI) {
        return YES;
    }];
    GHAssertTrue([response uriCheckBlock](nil), @"YESにならないのは変");
}


@end
