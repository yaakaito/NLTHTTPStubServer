//
//  NLTHTTPDataStubResponseTest.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPDataStubResponseTest.h"
#import "NLTHTTPDataStubResponse.h"
#import "NLTStubResponse.h"

@implementation NLTHTTPDataStubResponseTest
- (void)testHttpResponseProtocol {
    NSData *data = [@"hogehogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPDataStubResponse *response = [NLTStubResponse httpDataResponse];
    response.statusCode = 200;
    response.path = @"/index";
    response.data = data;
    response.httpHeaders = [NSDictionary dictionaryWithObject:@"text/html; charset=UTF-8" forKey:@"Content-Type"];
    
    GHAssertFalse([response isDone], @"まだ読み込みは完了していないはず");
    GHAssertEquals((UInt64)16, [response contentLength], @"contentLenghtが違う");
    GHAssertEquals((UInt64)0, [response offset], @"offsetはまだ0");
    
    NSData *readData = [response readDataOfLength:8];
    NSString *readDataString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(@"hogehoge", readDataString, @"取り出したデータの内容が違う");
    GHAssertFalse([response isDone], @"まだ読み込みは完了していないはず");
    
    GHAssertEquals((UInt64)8, [response offset], @"offsetは8になったはず");
    [response readDataOfLength:8];
    GHAssertTrue([response isDone], @"読み込みが完了しているはず");
    
    GHAssertEquals(200, [response status], @"ステータスコードが一致しない");
    GHAssertEqualObjects(@"text/html; charset=UTF-8", [response.httpHeaders objectForKey:@"Content-Type"], @"Content-Type違う");
}


- (void)testSupportCopy {
    
    NSData *data = [@"hogehogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPDataStubResponse *response = [NLTStubResponse httpDataResponse];
    response.statusCode = 200;
    response.path = @"/index";
    response.data = data;
    response.shouldTimeout = YES;
    response.httpHeaders = [NSDictionary dictionaryWithObject:@"text/html; charset=UTF-8" forKey:@"Content-Type"];
    [response URICheckWithBlock:^BOOL(NSURL *URI) {
        return YES;
    }];
    
    NLTHTTPDataStubResponse *copy = [response copy];

    GHAssertNotEqualObjects(response, copy, @"同じ物だったら困る");
    GHAssertEqualStrings(response.path, copy.path, @"pathはおなじ");
    
    GHAssertEqualStrings([[[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding] autorelease],
                         [[[NSString alloc] initWithData:copy.data encoding:NSUTF8StringEncoding] autorelease], @"レスポンス内容");
    GHAssertEquals(response.statusCode, copy.statusCode, @"ステータスコードが同じじゃない");
    GHAssertEquals(response.shouldTimeout, copy.shouldTimeout, @"shouldTimeoutが同じじゃない");
    GHAssertEquals([response.httpHeaders objectForKey:@"Content-Type"], [copy.httpHeaders objectForKey:@"Content-Type"], @"Content-Typeが同じじゃない");
}

@end
