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
    response.httpMethod = @"POST";
    response.processingTimeSeconds = 1.0f;
    GHAssertEqualStrings(@"/index", response.path, @"pathちがう");
    GHAssertEquals(200, response.statusCode, @"ステータスコード違う");
    GHAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
    GHAssertNotNil(response.httpHeaders, @"httpHeadersが存在しない");
    GHAssertNotNil([response.httpHeaders objectForKey:@"Content-Type"], @"Content-Typeが存在しない");
    GHAssertEqualObjects(@"text/html; charset=UTF-8", [response.httpHeaders objectForKey:@"Content-Type"], @"Content-Type違う");
    GHAssertEqualStrings(@"POST", response.httpMethod, @"httpMethodちがう");
    GHAssertTrue(1.0f == response.processingTimeSeconds, @"処理時間が違う");
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

- (void)testPostKeyValueBodyCheckBlock {
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    __block BOOL called = NO;
    [response postKeyValueBodyCheckWithBlock:^(NSDictionary *postBody) {
        called = YES;
    }];
    [response postKeyValueBodyCheckBlock](nil);
    GHAssertTrue(called, @"YESにならないのは変");
}

- (void)testPostBodyCheckBlock {
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    __block BOOL called = NO;
    [response postKeyValueBodyCheckWithBlock:^(NSDictionary *postBody) {
        called = YES;
    }];
    [response postKeyValueBodyCheckBlock](nil);
    GHAssertTrue(called, @"YESにならないのは変");
}

- (void)testChaining {
    
    __block BOOL called = NO;
    NLTHTTPStubResponse *stub = [[[[[[[NLTHTTPStubResponse httpDataResponse]
                                        forPath:@"/index"]
                                       andResponse:[@"hoge" dataUsingEncoding:NSUTF8StringEncoding]]
                                      andStatusCode:200]
                                     andCheckURI:^(NSURL *URI) {
                                         called = YES;
                                     }]
                                    andCheckKeyValuePostBody:^(NSDictionary *postBody) {
                                         called = YES;
                                     }]
                                   andCheckPostBody:^(NSData *postBody) {
                                       called = YES;
                                   }];
    
    
    GHAssertEqualStrings(@"/index", stub.path, @"パス指定が間違ってる");
    GHAssertEqualStrings(@"GET", stub.httpMethod, @"httpMethodが間違ってる");
    GHAssertEqualStrings(@"hoge", [[[NSString alloc] initWithData:stub.data encoding:NSUTF8StringEncoding] autorelease], @"データが違う");
    GHAssertEquals(200, stub.statusCode, @"ステータスコードが違う");
    stub.uriCheckBlock(nil);
    GHAssertTrue(called, @"チェックブロックがコールされない");
    called = NO;
    stub.postKeyValueBodyCheckBlock(nil);
    GHAssertTrue(called, @"チェックブロックがコールされない");
    called = NO;
    stub.postBodyCheckBlock(nil);
    GHAssertTrue(called, @"チェックブロックがコールされない");
    GHAssertFalse(stub.shouldTimeout, @"タイムアウトしない");
    
    [stub andTimeout];
    GHAssertTrue(stub.shouldTimeout, @"タイムアウトする");
    
    GHAssertTrue(0.0 == stub.processingTimeSeconds, @"処理時間は0");
    [stub andProcessingTime:1.0];
    GHAssertTrue(1.0 == stub.processingTimeSeconds, @"処理時間は1.0");
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
    
    NLTHTTPStubResponse *aliveHeader = [NLTHTTPStubResponse httpDataResponse];
    aliveHeader.httpHeaders = [NSDictionary dictionaryWithObject:@"hoge" forKey:@"fuga"];
    [aliveHeader andJSONHeader];
    GHAssertEquals(2U, [[aliveHeader.httpHeaders allKeys] count], @"ヘッダー2つ設定されているはず");
    GHAssertEqualStrings(@"application/json; charset=utf-8", [aliveHeader.httpHeaders objectForKey:@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hoge", [aliveHeader.httpHeaders objectForKey:@"fuga"], @"fuga = hoge");
}

- (void)testAndContentTypeWithData {
    
    NSData *data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
    
    NLTHTTPStubResponse *json = [[NLTHTTPStubResponse httpDataResponse] andJSONResponse:data];
    GHAssertEqualStrings(@"application/json; charset=utf-8", [json.httpHeaders objectForKey:@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:json.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *plain = [[NLTHTTPStubResponse httpDataResponse] andPlainResponse:data];
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [plain.httpHeaders objectForKey:@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:plain.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *html = [[NLTHTTPStubResponse httpDataResponse] andHTMLResponse:data];
    GHAssertEqualStrings(@"text/html; charset=utf-8", [html.httpHeaders objectForKey:@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:html.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");

    NLTHTTPStubResponse *xml = [[NLTHTTPStubResponse httpDataResponse] andXMLResponse:data];
    GHAssertEqualStrings(@"text/xml; charset=utf-8", [xml.httpHeaders objectForKey:@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:xml.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
}

- (void)testAndContentTypeAndCharset {
    
    NLTHTTPStubResponse *json = [[NLTHTTPStubResponse httpDataResponse] andJSONHeader:@"shift_jis"];
    GHAssertEqualStrings(@"application/json; charset=shift_jis", [json.httpHeaders objectForKey:@"Content-Type"], @"json");
    
    NLTHTTPStubResponse *plain = [[NLTHTTPStubResponse httpDataResponse] andPlainHeader:@"shift_jis"];
    GHAssertEqualStrings(@"text/plain; charset=shift_jis", [plain.httpHeaders objectForKey:@"Content-Type"], @"plain text");
    
    NLTHTTPStubResponse *html = [[NLTHTTPStubResponse httpDataResponse] andHTMLHeader:@"shift_jis"];
    GHAssertEqualStrings(@"text/html; charset=shift_jis", [html.httpHeaders objectForKey:@"Content-Type"], @"html");
    
    NLTHTTPStubResponse *xml = [[NLTHTTPStubResponse httpDataResponse] andXMLHeader:@"shift_jis"];
    GHAssertEqualStrings(@"text/xml; charset=shift_jis", [xml.httpHeaders objectForKey:@"Content-Type"], @"xml");
    
}

- (void)testAndContentTypeWithDataAndCharset {
    
    NSData *data = [@"hello" dataUsingEncoding:NSShiftJISStringEncoding];
    
    NLTHTTPStubResponse *json = [[NLTHTTPStubResponse httpDataResponse] andJSONResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"application/json; charset=shift_jis", [json.httpHeaders objectForKey:@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:json.data encoding:NSShiftJISStringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *plain = [[NLTHTTPStubResponse httpDataResponse] andPlainResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/plain; charset=shift_jis", [plain.httpHeaders objectForKey:@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:plain.data encoding:NSShiftJISStringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *html = [[NLTHTTPStubResponse httpDataResponse] andHTMLResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/html; charset=shift_jis", [html.httpHeaders objectForKey:@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:html.data encoding:NSShiftJISStringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *xml = [[NLTHTTPStubResponse httpDataResponse] andXMLResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/xml; charset=shift_jis", [xml.httpHeaders objectForKey:@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hello", [[[NSString alloc] initWithData:xml.data encoding:NSShiftJISStringEncoding] autorelease], @"data = hello");
}

- (void)testAndResponseResource {
    NLTHTTPStubResponse *stub = [NLTHTTPStubResponse httpDataResponse];
    [stub andResponseResource:@"test" ofType:@"txt"];
    NSString *response = [[NSString alloc] initWithData:stub.data encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(@"hogehogehogehoge", response, @"読み込み失敗してる");
    [response release];
}

- (void)testAndContentTypeWithResource {
    
    NLTHTTPStubResponse *json = [[NLTHTTPStubResponse httpDataResponse] andJSONResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"application/json; charset=utf-8", [json.httpHeaders objectForKey:@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:json.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *plain = [[NLTHTTPStubResponse httpDataResponse] andPlainResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [plain.httpHeaders objectForKey:@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:plain.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *html = [[NLTHTTPStubResponse httpDataResponse] andHTMLResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"text/html; charset=utf-8", [html.httpHeaders objectForKey:@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:html.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *xml = [[NLTHTTPStubResponse httpDataResponse] andXMLResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"text/xml; charset=utf-8", [xml.httpHeaders objectForKey:@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:xml.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");

}

- (void)testAndContentTypeWithResourceAndCharset {
    
    NLTHTTPStubResponse *json = [[NLTHTTPStubResponse httpDataResponse] andJSONResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"application/json; charset=shift_jis", [json.httpHeaders objectForKey:@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:json.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *plain = [[NLTHTTPStubResponse httpDataResponse] andPlainResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/plain; charset=shift_jis", [plain.httpHeaders objectForKey:@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:plain.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *html = [[NLTHTTPStubResponse httpDataResponse] andHTMLResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/html; charset=shift_jis", [html.httpHeaders objectForKey:@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:html.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
    NLTHTTPStubResponse *xml = [[NLTHTTPStubResponse httpDataResponse] andXMLResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/xml; charset=shift_jis", [xml.httpHeaders objectForKey:@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hogehogehogehoge", [[[NSString alloc] initWithData:xml.data encoding:NSUTF8StringEncoding] autorelease], @"data = hello");
    
}
@end
