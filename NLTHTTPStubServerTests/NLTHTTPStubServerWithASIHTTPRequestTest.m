//
//  NLTHTTPStubServerWithASIHTTPRequestTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubServerWithASIHTTPRequestTest.h"
#import "ASIHTTPRequest.h"

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
    [server addStubResponse:stub];
     
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];

    
    GHAssertEqualStrings(@"Hello World", [request responseString], @"レスポンス内容が違う");
}

- (void)testFile {
    NLTHTTPStubResponse *stub = [NLTStubResponse httpFileResponse];
    stub.path = @"/index";
    stub.filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                     ofType:@"txt"];
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"hogehogehogehoge", [request responseString], @"レスポンス内容が違う");
}

- (void)testCheckQuery {
    NLTHTTPStubResponse *stub = [NLTStubResponse httpFileResponse];
    stub.path = @"/index";
    stub.filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                     ofType:@"txt"];
    [stub URICheckWithBlock:^BOOL(NSURL *URI) {
        GHAssertEqualStrings(@"key=value", [URI query], @"queryが一致しない");
        return YES;
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
}


- (void)testJSON {
    NSData *jsonData = [@"{\"status\":\"ok\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = jsonData;
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
    [server addStubResponse:stub1];
    
    NSData *response2 = [@"2" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub2 = [NLTStubResponse httpDataResponse];
    stub2.path = @"/two";
    stub2.data = response2;
    [server addStubResponse:stub2];
    
    ASIHTTPRequest *request1 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/one"]];
    [self prepare];
    [request1 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request1 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEqualStrings(@"1", [request1 responseString], @"レスポンス内容が違う");
    
    ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/two"]];
    [self prepare];
    [request2 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request2 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEqualStrings(@"2", [request2 responseString], @"レスポンス内容が違う");
    
}


- (void)testDeepPath {
    
    NSData *helloWorld = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/h/e/l/l/o/w/o/r/l/d";
    stub.data = helloWorld;
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/h/e/l/l/o/w/o/r/l/d"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"Hello World", [request responseString], @"レスポンス内容が違う");
}

- (void)testDuplicated {
    NSData *response1 = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub1 = [NLTStubResponse httpDataResponse];
    stub1.path = @"/index";
    stub1.data = response1;
    [server addStubResponse:stub1];
    
    NSData *response2 = [@"2" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub2 = [NLTStubResponse httpDataResponse];
    stub2.path = @"/index";
    stub2.data = response2;
    [server addStubResponse:stub2];
    
    ASIHTTPRequest *request1 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request1 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request1 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"1", [request1 responseString], @"レスポンス内容が違う");
    
    ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request2 setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request2 startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    
    GHAssertEqualStrings(@"2", [request2 responseString], @"レスポンス内容が違う");
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
@end
