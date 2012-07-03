//
//  NLTHTTPStubServerWithASIHTTPRequestTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubServerWithASIHTTPRequestTest.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation NLTHTTPStubServerWithASIHTTPRequestTest

- (void)setUpClass {
    [NLTHTTPStubServer globalSettings].port = 12345;
    
    server = [[NLTHTTPStubServer stubServer] retain];
    [server startServer];
}

- (void)tearDownClass {

    [server stopServer];
    [server release];
}

- (void)setUp {
    [server clear];
}

- (void)tearDown {
    if(![server isStubEmpty]) {
        GHFail(@"stubs not empty");
    }
}

- (void)testText {
    
    NSData *helloWorld = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = helloWorld;
    stub.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub];
     
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];

    
    GHAssertEqualStrings(@"Hello World", [request responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}

- (void)testFile {
    NLTHTTPStubResponse *stub = [NLTStubResponse httpFileResponse];
    stub.path = @"/index";
    stub.filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                     ofType:@"txt"];
    stub.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"hogehogehogehoge", [request responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}

- (void)testCheckQuery {
    NLTHTTPStubResponse *stub = [NLTStubResponse httpFileResponse];
    stub.path = @"/index";
    stub.filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                     ofType:@"txt"];
    stub.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [stub URICheckWithBlock:^(NSURL *URI) {
        GHAssertEqualStrings(@"key=value", [URI query], @"queryが一致しない");
    }];
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index?key=value"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEqualStrings(@"hogehogehogehoge", [request responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}


- (void)testJSON {
    NSData *jsonData = [@"{\"status\":\"ok\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = jsonData;
    stub.httpHeaders = [NSDictionary dictionaryWithObject:@"application/json; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    NSError *error=nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingAllowFragments error:&error];   
    GHTestLog(@"%@", json.description);
    GHAssertEqualStrings(@"ok", [json objectForKey:@"status"], @"status=okじゃない");
    GHAssertEqualStrings(@"application/json; charset=utf-8", [[request responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}

- (void)testNotFound {
    NSData *notFound = [@"404 Not Found" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.statusCode = 404;
    stub.data = notFound;
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEquals(404, [request responseStatusCode], @"ステータスコードが違う");
    GHAssertEqualStrings(@"404 Not Found", [request responseString], @"レスポンス内容が違う");
}

- (void)testTwice {
    NSData *response1 = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub1 = [NLTStubResponse httpDataResponse];
    stub1.path = @"/one";
    stub1.data = response1;
    stub1.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub1];
    
    NSData *response2 = [@"2" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub2 = [NLTStubResponse httpDataResponse];
    stub2.path = @"/two";
    stub2.data = response2;
    stub2.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub2];
    
    ASIHTTPRequest *request1 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/one"]];
    [self prepare];
    [request1 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request1 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEqualStrings(@"1", [request1 responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request1 responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
    
    ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/two"]];
    [self prepare];
    [request2 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request2 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEqualStrings(@"2", [request2 responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request2 responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}


- (void)testDeepPath {
    
    NSData *helloWorld = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/h/e/l/l/o/w/o/r/l/d";
    stub.data = helloWorld;
    stub.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/h/e/l/l/o/w/o/r/l/d"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"Hello World", [request responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}

- (void)testDuplicated {
    NSData *response1 = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub1 = [NLTStubResponse httpDataResponse];
    stub1.path = @"/index";
    stub1.data = response1;
    stub1.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub1];
    
    NSData *response2 = [@"2" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub2 = [NLTStubResponse httpDataResponse];
    stub2.path = @"/index";
    stub2.data = response2;
    stub2.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub2];
    
    ASIHTTPRequest *request1 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request1 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request1 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"1", [request1 responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request1 responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
    
    ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request2 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request2 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"2", [request2 responseString], @"レスポンス内容が違う");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request2 responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}

- (void)testTimeout {
    
    NSData *response = [@"hoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = response;
    stub.shouldTimeout = YES;
    [server addStubResponse:stub];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    request.timeOutSeconds = 2.0f;
    [request startSynchronous];
    GHAssertEquals(request.error.code, ASIRequestTimedOutErrorType, @"oops...");
}

- (void)testProcessingTime {
    NSData *response = [@"hoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = response;
    stub.processingTimeSeconds = 2.0;
    [server addStubResponse:stub];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    NSDate *t1 = [NSDate date];
    [request startSynchronous];
    GHAssertTrue(-[t1 timeIntervalSinceNow] > 1.9,  @"ちゃんと待ってない");
}

- (void)testCopyStub {
    
    NSData *response = [@"hoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = response;
    stub.httpHeaders = [NSDictionary dictionaryWithObject:@"text/plain; charset=utf-8" forKey:@"Content-Type"];
    [server addStubResponse:stub];
    [server addStubResponse:[stub copy]];
    NLTHTTPStubResponse *stubCopy = [stub copy];
    stubCopy.path = @"/copy";
    [server addStubResponse:stubCopy];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [request startSynchronous];
    GHAssertEqualStrings(@"hoge", [request responseString], @"oh...");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[request responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
    
    ASIHTTPRequest *requestCopy = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [requestCopy startSynchronous];
    GHAssertEqualStrings(@"hoge", [requestCopy responseString], @"copy :(");
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[requestCopy responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
    
    ASIHTTPRequest *requestCopyAndChange = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/copy"]];
    [requestCopyAndChange startSynchronous];
    GHAssertEqualStrings(@"hoge", [requestCopyAndChange responseString], @"copy and change :("); 
    GHAssertEqualStrings(@"text/plain; charset=utf-8", [[requestCopyAndChange responseHeaders] objectForKey:@"Content-Type"], @"Content-Typeが違う");
}

- (void)testPostRequest {
    
    [[[server stub] forPath:@"/post-index" HTTPMethod:@"POST"] andPlainResponse:[@"hoge" dataUsingEncoding:NSUTF8StringEncoding]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/post-index"]];
    [request addPostValue:@"post-value1" forKey:@"post-key1"];
    [request addPostValue:@"post-value2" forKey:@"post-key2"];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    GHAssertEqualStrings(@"hoge", response, @"レスポンス内容あってないよ");
    
}

- (void)testPostRequestAndCheckKeyValue {
    
    [[[[server stub] forPath:@"/post-index" HTTPMethod:@"POST"] andPlainResponse:[@"hoge" dataUsingEncoding:NSUTF8StringEncoding]] andCheckKeyValuePostBody:^(NSDictionary *postBody){
        GHAssertEqualStrings(@"post-value1", [postBody objectForKey:@"post-key1"],@"ポストされたデータが違う");
        GHAssertEqualStrings(@"post-value2", [postBody objectForKey:@"post-key2"],@"ポストされたデータが違う");
    }];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/post-index"]];
    [request addPostValue:@"post-value1" forKey:@"post-key1"];
    [request addPostValue:@"post-value2" forKey:@"post-key2"];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    GHAssertEqualStrings(@"hoge", response, @"レスポンス内容あってないよ");
    
}

- (void)testPostRequestAndCheckBody {
    
    [[[[server stub] forPath:@"/post-index" HTTPMethod:@"POST"] andPlainResponse:[@"hoge" dataUsingEncoding:NSUTF8StringEncoding]] andCheckPostBody:^(NSData *postBody) {
        NSString *dataStr = [[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding];
        GHAssertEqualStrings(@"hogehogehoge", dataStr, @"ポストされたデータが違う");
    }];
    NSData *data = [@"hogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/post-index"]];
    [request setPostBody:[[data mutableCopy] autorelease]];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    GHAssertEqualStrings(@"hoge", response, @"レスポンス内容あってないよ");
    
}
@end
