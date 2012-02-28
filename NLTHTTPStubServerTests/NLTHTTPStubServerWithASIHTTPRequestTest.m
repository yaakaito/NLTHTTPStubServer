//
//  NLTHTTPStubServerWithASIHTTPRequestTest.m
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
    [server addStubResponse:[NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                           statusCode:200
                                                                 data:helloWorld]];
     
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];

    
    GHAssertEquals(200, [request responseStatusCode], @"ステータスコードが違う");
    GHAssertEqualStrings(@"Hello World", [request responseString], @"レスポンス内容が違う");
}


- (void)testJSON {
    NSData *jsonData = [@"{\"status\":\"ok\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [server addStubResponse:[NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                           statusCode:200
                                                                 data:jsonData]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEquals(200, [request responseStatusCode], @"ステータスコードが違う");
    
    NSError *error=nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingAllowFragments error:&error];   
    GHTestLog(@"%@", json.description);
    GHAssertEqualStrings(@"ok", [json objectForKey:@"status"], @"status=okじゃない");

}

- (void)testNotFound {
    NSData *notFound = [@"404 Not Found" dataUsingEncoding:NSUTF8StringEncoding];
    [server addStubResponse:[NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                           statusCode:404
                                                                 data:notFound]];
    
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

@end
