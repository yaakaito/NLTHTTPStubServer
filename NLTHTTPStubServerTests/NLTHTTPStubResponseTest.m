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
    GHAssertEqualStrings(@"/index", response.path, @"pathちがう");
    GHAssertEquals(200, response.statusCode, @"ステータスコード違う");
    GHAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
}

- (void)testURICheckBlock {
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    [response URICheckWithBlock:^BOOL(NSURL *URI) {
        return YES;
    }];
    GHAssertTrue([response uriCheckBlock](nil), @"YESにならないのは変");
}


@end
