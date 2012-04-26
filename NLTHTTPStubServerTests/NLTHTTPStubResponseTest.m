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
    __block BOOL called = NO;
    [response URICheckWithBlock:^(NSURL *URI) {
        called = YES;
    }];
    [response uriCheckBlock](nil);
    GHAssertTrue(called, @"YESにならないのは変");
}

- (void)testChaining {
    
    __block BOOL called = NO;
    NLTHTTPStubResponse *stub = [[[[[NLTHTTPStubResponse httpDataResponse]
                                        forPath:@"/index"]
                                       andResponse:[@"hoge" dataUsingEncoding:NSUTF8StringEncoding]]
                                      andStatusCode:200]
                                     andCheckURI:^(NSURL *URI) {
                                         called = YES;
                                     }];
    
    
    GHAssertEqualStrings(@"/index", stub.path, @"パス指定が間違ってる");
    GHAssertEqualStrings(@"hoge", [[[NSString alloc] initWithData:stub.data encoding:NSUTF8StringEncoding] autorelease], @"データが違う");
    GHAssertEquals(200, stub.statusCode, @"ステータスコードが違う");
    stub.uriCheckBlock(nil);
    GHAssertTrue(called, @"チェックブロックがコールされない");
}

- (void)testAndContentType {
    
    NLTHTTPStubResponse *json = [[NLTHTTPStubResponse httpDataResponse] andJSONHeader];
    GHAssertEqualStrings(@"application/json; charset=utf-8", [json.httpHeaders objectForKey:@"Content-Type"], @"json");
    NLTHTTPStubResponse *plain = [[NLTHTTPStubResponse httpDataResponse] andPlainHeader];
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [plain.httpHeaders objectForKey:@"Content-Type"], @"plain text");
    NLTHTTPStubResponse *html = [[NLTHTTPStubResponse httpDataResponse] andHTMLHeader];
    GHAssertEqualStrings(@"text/html; charset=utf-8", [html.httpHeaders objectForKey:@"Content-Type"], @"html");
    NLTHTTPStubResponse *xml = [[NLTHTTPStubResponse httpDataResponse] andXMLHeader];
    GHAssertEqualStrings(@"text/xml; charset=utf-8", [xml.httpHeaders objectForKey:@"Content-Type"], @"xml");
    
}

@end
