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
    NLTHTTPStubResponse *response = [NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                                   statusCode:200
                                                                         data:[NSData data]];
    [[[stubServer stub] andReturn:response] responseForPath:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[NLTHTTPStubConnection alloc] init];
    connection.stubServer = stubServer;

    NSObject<HTTPResponse> *returnResponse = [connection httpResponseForMethod:@"GET"
                                                                        URI:@"/index"];
    GHAssertNotNil(returnResponse, @"/indexのstubを取得できるはずだが");
    GHAssertEquals(returnResponse, response, @"同じ物のはずだが、一致しない");
}

- (void)testResponseNothing {
    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    [[[stubServer stub] andReturn:nil] responseForPath:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[NLTHTTPStubConnection alloc] init];
    connection.stubServer = stubServer;
    GHAssertThrows([connection httpResponseForMethod:@"GET"
                                                 URI:@"/index"], @"存在しないので例外が投げられるはず");
 
}

@end
