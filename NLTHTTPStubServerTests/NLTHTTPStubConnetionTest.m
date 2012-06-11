//
//  NLTHTTPStubConnetionTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubConnetionTest.h"
#import "NLTHTTPStubServer.h"
#import "NLTHTTPStubConnection.h"
#import "NLTHTTPStubResponse.h"
#import "OCMock.h"

@implementation NLTHTTPStubConnetionTest

- (void)testResponseExists {
    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    response.statusCode = 200;
    response.path = @"/index";
    response.data = [NSData data];
    [[[stubServer stub] andReturn:response] responseForPath:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[[NLTHTTPStubConnection alloc] init] autorelease];
    connection.stubServer = stubServer;

    NSObject<HTTPResponse> *returnResponse = [connection httpResponseForMethod:@"GET"
                                                                        URI:@"/index"];
    GHAssertNotNil(returnResponse, @"/indexのstubを取得できるはずだが");
    GHAssertEquals(returnResponse, response, @"同じ物のはずだが、一致しない");
}

- (void)testResponseNothing {
    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    [[[stubServer stub] andReturn:nil] responseForPath:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[[NLTHTTPStubConnection alloc] init] autorelease];
    connection.stubServer = stubServer;
    GHAssertThrows([connection httpResponseForMethod:@"GET"
                                                 URI:@"/index"], @"存在しないので例外が投げられるはず");
 
}

- (void)testCallURICheckBlock {
    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    response.path = @"/index";
    __block BOOL called = NO;
    [response URICheckWithBlock:^(NSURL *URI) {
        GHAssertEqualStrings(@"hoge=1", [URI query], @"queryが不一致");
        called = YES;
    }];

    [[[stubServer stub] andReturn:response] responseForPath:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[[NLTHTTPStubConnection alloc] init] autorelease];
    connection.stubServer = stubServer;
    
   [connection httpResponseForMethod:@"GET" URI:@"/index?hoge=1"];
    GHAssertTrue(called, @"checkblockが呼ばれていない");
}

- (void)testCallPostBodyCheckBlock {
    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    response.path = @"/index";
    __block BOOL called = NO;
    [response postBodyCheckWithBlock:^(NSDictionary *postBody) {
        GHAssertEqualStrings(@"1", [postBody objectForKey:@"hoge"], @"valueが不一致");
        called = YES;
    }];
    
    [[[stubServer stub] andReturn:response] responseForPath:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[[NLTHTTPStubConnection alloc] init] autorelease];
    connection.stubServer = stubServer;
    
    [connection processBodyData:[@"hoge=1" dataUsingEncoding:NSUTF8StringEncoding]];
    [connection httpResponseForMethod:@"POST" URI:@"/index"];
    GHAssertTrue(called, @"checkblockが呼ばれていない");
}
@end