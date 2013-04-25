//
//  NLTHTTPStubResponseTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubResponseTest.h"
#import "NLTHTTPStubResponse.h"
#import "NLTHTTPDataStubResponse.h"

@implementation NLTHTTPStubResponseTest

- (void)testResponseWith {
    NLTHTTPStubResponse *response = [[NLTHTTPDataStubResponse alloc] init];
    response.statusCode = 200;
    response.path = [NLTPath pathWithPathString:@"/index"];
    response.data = [NSData data];
    response.shouldTimeout = YES;
    response.httpHeaders = @{@"Content-Type": @"text/html; charset=UTF-8"};
    response.httpMethod = @"POST";
    response.processingTimeSeconds = 1.0f;
    GHAssertEqualStrings(@"/index", response.path.pathString, @"pathStringちがう");
    GHAssertEquals(200, response.statusCode, @"ステータスコード違う");
    GHAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
    GHAssertNotNil(response.httpHeaders, @"httpHeadersが存在しない");
    GHAssertNotNil((response.httpHeaders)[@"Content-Type"], @"Content-Typeが存在しない");
    GHAssertEqualObjects(@"text/html; charset=UTF-8", (response.httpHeaders)[@"Content-Type"], @"Content-Type違う");
    GHAssertEqualStrings(@"POST", response.httpMethod, @"httpMethodちがう");
    GHAssertTrue(1.0f == response.processingTimeSeconds, @"処理時間が違う");
}

- (void)testPostKeyValueBodyCheckBlock {
    NLTHTTPStubResponse *response = [[NLTHTTPDataStubResponse alloc] init];
    __block BOOL called = NO;
    [response postKeyValueBodyCheckWithBlock:^(NSDictionary *postBody) {
        called = YES;
    }];
    [response postKeyValueBodyCheckBlock](nil);
    GHAssertTrue(called, @"YESにならないのは変");
}

- (void)testPostBodyCheckBlock {
    NLTHTTPStubResponse *response = [[NLTHTTPDataStubResponse alloc] init];
    __block BOOL called = NO;
    [response postKeyValueBodyCheckWithBlock:^(NSDictionary *postBody) {
        called = YES;
    }];
    [response postKeyValueBodyCheckBlock](nil);
    GHAssertTrue(called, @"YESにならないのは変");
}

- (void)testChaining {
    
    __block BOOL called = NO;
    NLTHTTPStubResponse *stub = [[[[[[[NLTHTTPDataStubResponse alloc] init]
                                        forPath:@"/index"]
                                       andResponse:[@"hoge" dataUsingEncoding:NSUTF8StringEncoding]]
                                      andStatusCode:200]
                                    andCheckKeyValuePostBody:^(NSDictionary *postBody) {
                                         called = YES;
                                     }]
                                   andCheckPostBody:^(NSData *postBody) {
                                       called = YES;
                                   }];
    
    
    GHAssertEqualStrings(@"/index", stub.path.pathString, @"パス指定が間違ってる");
    GHAssertEqualStrings(@"GET", stub.httpMethod, @"httpMethodが間違ってる");
    GHAssertEqualStrings(@"hoge", [[NSString alloc] initWithData:stub.data encoding:NSUTF8StringEncoding], @"データが違う");
    GHAssertEquals(200, stub.statusCode, @"ステータスコードが違う");
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
    
    NLTHTTPStubResponse *json = [[[NLTHTTPDataStubResponse alloc] init] andJSONHeader];
    GHAssertEqualStrings(@"application/json; charset=utf-8", (json.httpHeaders)[@"Content-Type"], @"json");
    
    NLTHTTPStubResponse *plain = [[[NLTHTTPDataStubResponse alloc] init] andPlainHeader];
    GHAssertEqualStrings(@"text/plain; charset=utf-8", (plain.httpHeaders)[@"Content-Type"], @"plain text");
    
    NLTHTTPStubResponse *html = [[[NLTHTTPDataStubResponse alloc] init] andHTMLHeader];
    GHAssertEqualStrings(@"text/html; charset=utf-8", (html.httpHeaders)[@"Content-Type"], @"html");
    
    NLTHTTPStubResponse *xml = [[[NLTHTTPDataStubResponse alloc] init] andXMLHeader];
    GHAssertEqualStrings(@"text/xml; charset=utf-8", (xml.httpHeaders)[@"Content-Type"], @"xml");
    
    NLTHTTPStubResponse *binary = [[[NLTHTTPDataStubResponse alloc] init] andBinaryHeader];
    GHAssertEqualStrings(@"application/octet-stream", (binary.httpHeaders)[@"Content-Type"], @"binary");
    
    NLTHTTPStubResponse *contentType = [[[NLTHTTPDataStubResponse alloc] init] andContentTypeHeader:@"image/png"];
    GHAssertEqualStrings(@"image/png", (contentType.httpHeaders)[@"Content-Type"], @"content-type");
    
    NLTHTTPStubResponse *aliveHeader = [[NLTHTTPDataStubResponse alloc] init];
    aliveHeader.httpHeaders = @{@"fuga": @"hoge"};
    [aliveHeader andJSONHeader];
    GHAssertEquals(2U, [[aliveHeader.httpHeaders allKeys] count], @"ヘッダー2つ設定されているはず");
    GHAssertEqualStrings(@"application/json; charset=utf-8", (aliveHeader.httpHeaders)[@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hoge", (aliveHeader.httpHeaders)[@"fuga"], @"fuga = hoge");
    
    NLTHTTPStubResponse *overwriteHeader = [[NLTHTTPDataStubResponse alloc] init];
    overwriteHeader.httpHeaders = @{@"fuga": @"hoge"};
    [overwriteHeader andJSONHeader];
    [overwriteHeader andPlainHeader];
    GHAssertEquals(2U, [[overwriteHeader.httpHeaders allKeys] count], @"ヘッダー2つ設定されているはず");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", (overwriteHeader.httpHeaders)[@"Content-Type"], @"plain textがjsonを上書きしているはず");
    GHAssertEqualStrings(@"hoge", (overwriteHeader.httpHeaders)[@"fuga"], @"fuga = hoge");
}

- (void)testAndJSONObject {

    NLTHTTPStubResponse *jsonObject = [[[NLTHTTPDataStubResponse alloc] init] andJSONResponseObject:@{ @"HOGE" : @"FUGA"}];
    GHAssertEqualStrings(@"application/json; charset=utf-8", jsonObject.httpHeaders[@"Content-Type"], @"json");

    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonObject.data options:NSJSONReadingAllowFragments error:nil];
    GHAssertEqualStrings(@"FUGA",  JSON[@"HOGE"], nil);

}

- (void)testAndContentTypeWithData {
    
    NSData *data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
    
    NLTHTTPStubResponse *json = [[[NLTHTTPDataStubResponse alloc] init] andJSONResponse:data];
    GHAssertEqualStrings(@"application/json; charset=utf-8", (json.httpHeaders)[@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:json.data encoding:NSUTF8StringEncoding], @"data = hello");

    NLTHTTPStubResponse *plain = [[[NLTHTTPDataStubResponse alloc] init] andPlainResponse:data];
    GHAssertEqualStrings(@"text/plain; charset=utf-8", (plain.httpHeaders)[@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:plain.data encoding:NSUTF8StringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *html = [[[NLTHTTPDataStubResponse alloc] init] andHTMLResponse:data];
    GHAssertEqualStrings(@"text/html; charset=utf-8", (html.httpHeaders)[@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:html.data encoding:NSUTF8StringEncoding], @"data = hello");

    NLTHTTPStubResponse *xml = [[[NLTHTTPDataStubResponse alloc] init] andXMLResponse:data];
    GHAssertEqualStrings(@"text/xml; charset=utf-8", (xml.httpHeaders)[@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:xml.data encoding:NSUTF8StringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *binary = [[[NLTHTTPDataStubResponse alloc] init] andBinaryResponse:data];
    GHAssertEqualStrings(@"application/octet-stream", (binary.httpHeaders)[@"Content-Type"], @"binary");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:binary.data encoding:NSUTF8StringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *contentType = [[[NLTHTTPDataStubResponse alloc] init] andContentType:@"image/png" response:data];
    GHAssertEqualStrings(@"image/png", (contentType.httpHeaders)[@"Content-Type"], @"content-type");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:contentType.data encoding:NSUTF8StringEncoding], @"data = hello");
}

- (void)testAndContentTypeAndCharset {
    
    NLTHTTPStubResponse *json = [[[NLTHTTPDataStubResponse alloc] init] andJSONHeader:@"shift_jis"];
    GHAssertEqualStrings(@"application/json; charset=shift_jis", (json.httpHeaders)[@"Content-Type"], @"json");
    
    NLTHTTPStubResponse *plain = [[[NLTHTTPDataStubResponse alloc] init] andPlainHeader:@"shift_jis"];
    GHAssertEqualStrings(@"text/plain; charset=shift_jis", (plain.httpHeaders)[@"Content-Type"], @"plain text");
    
    NLTHTTPStubResponse *html = [[[NLTHTTPDataStubResponse alloc] init] andHTMLHeader:@"shift_jis"];
    GHAssertEqualStrings(@"text/html; charset=shift_jis", (html.httpHeaders)[@"Content-Type"], @"html");
    
    NLTHTTPStubResponse *xml = [[[NLTHTTPDataStubResponse alloc] init] andXMLHeader:@"shift_jis"];
    GHAssertEqualStrings(@"text/xml; charset=shift_jis", (xml.httpHeaders)[@"Content-Type"], @"xml");
    
}

- (void)testAndContentTypeWithDataAndCharset {
    
    NSData *data = [@"hello" dataUsingEncoding:NSShiftJISStringEncoding];
    
    NLTHTTPStubResponse *json = [[[NLTHTTPDataStubResponse alloc] init] andJSONResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"application/json; charset=shift_jis", (json.httpHeaders)[@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:json.data encoding:NSShiftJISStringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *plain = [[[NLTHTTPDataStubResponse alloc] init] andPlainResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/plain; charset=shift_jis", (plain.httpHeaders)[@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:plain.data encoding:NSShiftJISStringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *html = [[[NLTHTTPDataStubResponse alloc] init] andHTMLResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/html; charset=shift_jis", (html.httpHeaders)[@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:html.data encoding:NSShiftJISStringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *xml = [[[NLTHTTPDataStubResponse alloc] init] andXMLResponse:data charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/xml; charset=shift_jis", (xml.httpHeaders)[@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hello", [[NSString alloc] initWithData:xml.data encoding:NSShiftJISStringEncoding], @"data = hello");
}

- (void)testAndResponseResource {
    NLTHTTPStubResponse *stub = [[NLTHTTPDataStubResponse alloc] init];
    [stub andResponseResource:@"test" ofType:@"txt"];
    NSString *response = [[NSString alloc] initWithData:stub.data encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(@"hogehogehogehoge", response, @"読み込み失敗してる");
}

- (void)testAndContentTypeWithResource {
    
    NLTHTTPStubResponse *json = [[[NLTHTTPDataStubResponse alloc] init] andJSONResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"application/json; charset=utf-8", (json.httpHeaders)[@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:json.data encoding:NSUTF8StringEncoding], @"data = hogehogehogehoge");
    
    NLTHTTPStubResponse *plain = [[[NLTHTTPDataStubResponse alloc] init] andPlainResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"text/plain; charset=utf-8", (plain.httpHeaders)[@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:plain.data encoding:NSUTF8StringEncoding], @"data = hogehogehogehoge");
    
    NLTHTTPStubResponse *html = [[[NLTHTTPDataStubResponse alloc] init] andHTMLResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"text/html; charset=utf-8", (html.httpHeaders)[@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:html.data encoding:NSUTF8StringEncoding], @"data = hogehogehogehoge");
    
    NLTHTTPStubResponse *xml = [[[NLTHTTPDataStubResponse alloc] init] andXMLResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"text/xml; charset=utf-8", (xml.httpHeaders)[@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:xml.data encoding:NSUTF8StringEncoding], @"data = hogehogehogehoge");
    
    NLTHTTPStubResponse *binary = [[[NLTHTTPDataStubResponse alloc] init] andBinaryResponseResource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"application/octet-stream", (binary.httpHeaders)[@"Content-Type"], @"binary");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:binary.data encoding:NSUTF8StringEncoding], @"data = hogehogehogehoge");
    
    NLTHTTPStubResponse *contentType = [[[NLTHTTPDataStubResponse alloc] init] andContentType:@"image/png" resource:@"test" ofType:@"txt"];
    GHAssertEqualStrings(@"image/png", (contentType.httpHeaders)[@"Content-Type"], @"binary");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:contentType.data encoding:NSUTF8StringEncoding], @"data = hogehogehogehoge");
}

- (void)testAndContentTypeWithResourceAndCharset {
    
    NLTHTTPStubResponse *json = [[[NLTHTTPDataStubResponse alloc] init] andJSONResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"application/json; charset=shift_jis", (json.httpHeaders)[@"Content-Type"], @"json");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:json.data encoding:NSUTF8StringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *plain = [[[NLTHTTPDataStubResponse alloc] init] andPlainResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/plain; charset=shift_jis", (plain.httpHeaders)[@"Content-Type"], @"plain text");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:plain.data encoding:NSUTF8StringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *html = [[[NLTHTTPDataStubResponse alloc] init] andHTMLResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/html; charset=shift_jis", (html.httpHeaders)[@"Content-Type"], @"html");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:html.data encoding:NSUTF8StringEncoding], @"data = hello");
    
    NLTHTTPStubResponse *xml = [[[NLTHTTPDataStubResponse alloc] init] andXMLResponseResource:@"test" ofType:@"txt" charset:@"shift_jis"];
    GHAssertEqualStrings(@"text/xml; charset=shift_jis", (xml.httpHeaders)[@"Content-Type"], @"xml");
    GHAssertEqualStrings(@"hogehogehogehoge", [[NSString alloc] initWithData:xml.data encoding:NSUTF8StringEncoding], @"data = hello");
    
}

- (void)testInvalidPath {
    NLTHTTPStubResponse *stub = [[NLTHTTPDataStubResponse alloc] init];
    GHAssertThrows([stub forPath:@[]], @"NLTPathかNSStringしか受け付けない");
}
@end
