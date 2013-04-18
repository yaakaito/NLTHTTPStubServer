//
//  NLTHTTPDataStubResponseTest.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPDataStubResponseTest.h"
#import "NLTHTTPDataStubResponse.h"

@implementation NLTHTTPDataStubResponseTest
- (void)testHttpResponseProtocol {
    NSData *data = [@"hogehogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPDataStubResponse *response = [[NLTHTTPDataStubResponse alloc] init];
    response.statusCode = 200;
    response.path = [NLTPath pathWithPathString:@"/index"];
    response.data = data;
    response.httpHeaders = @{@"Content-Type": @"text/html; charset=UTF-8"};
    
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
    GHAssertEqualObjects(@"text/html; charset=UTF-8", (response.httpHeaders)[@"Content-Type"], @"Content-Type違う");
}


- (void)testSupportCopy {
    
    NSData *data = [@"hogehogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPDataStubResponse *response = [[NLTHTTPDataStubResponse alloc] init];
    response.statusCode = 200;
    response.path = [NLTPath pathWithPathString:@"/index"];
    response.data = data;
    response.shouldTimeout = YES;
    response.httpHeaders = @{@"Content-Type": @"text/html; charset=UTF-8"};
    [response URICheckWithBlock:^(NSURL *URI) {
    }];
    
    NLTHTTPDataStubResponse *copy = [response copy];

    GHAssertNotEqualObjects(response, copy, @"同じ物だったら困る");
    GHAssertEqualStrings(response.path.pathString, copy.path.pathString, @"pathStringはおなじ");
    
    GHAssertEqualStrings([[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding],
                         [[NSString alloc] initWithData:copy.data encoding:NSUTF8StringEncoding], @"レスポンス内容");
    GHAssertEquals(response.statusCode, copy.statusCode, @"ステータスコードが同じじゃない");
    GHAssertEquals(response.shouldTimeout, copy.shouldTimeout, @"shouldTimeoutが同じじゃない");
    
    
    GHAssertEquals(response.httpHeaders[@"Content-Type"], copy.httpHeaders[@"Content-Type"], @"Content-Typeが同じじゃない");
}


@end
