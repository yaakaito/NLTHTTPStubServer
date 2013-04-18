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
#import "NLTHTTPDataStubResponse.h"
#import "OCMock.h"

@implementation NLTHTTPStubConnetionTest

- (void)testResponseExists {
    NLTHTTPStubResponse *response = [[NLTHTTPDataStubResponse alloc] init];
    [[[response forPath:@"/index"] andStatusCode:200] andPlainResponse:[NSData data]];

    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    [[[stubServer stub] andReturn:response] responseForPath:[OCMArg any] HTTPMethod:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[NLTHTTPStubConnection alloc] init];
    connection.stubServer = stubServer;

    NSObject<HTTPResponse> *returnResponse = [connection httpResponseForMethod:@"GET"
                                                                           URI:@"/index"];
    GHAssertNotNil(returnResponse, @"/indexのstubを取得できるはずだが");
    GHAssertEquals(returnResponse, response, @"同じ物のはずだが、一致しない");
}

- (void)testResponseNothing {
    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    [[[stubServer stub] andReturn:nil] responseForPath:[OCMArg any] HTTPMethod:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[NLTHTTPStubConnection alloc] init];
    connection.stubServer = stubServer;
    GHAssertThrows([connection httpResponseForMethod:@"GET"
                                                 URI:@"/index"], @"存在しないので例外が投げられるはず");
 
}

- (void)testCallPostBodyCheckBlock {
    id stubServer = [OCMockObject mockForClass:[NLTHTTPStubServer class]];
    NLTHTTPStubResponse *response = [[NLTHTTPDataStubResponse alloc] init];
    response.path = [NLTPath pathWithPathString:@"/index"];
    __block BOOL called = NO;
    [response postKeyValueBodyCheckWithBlock:^(NSDictionary *postBody) {
        GHAssertEqualStrings(@"1", postBody[@"hoge"], @"valueが不一致");
        called = YES;
    }];
    
    [[[stubServer stub] andReturn:response] responseForPath:[OCMArg any] HTTPMethod:[OCMArg any]];
    
    NLTHTTPStubConnection *connection = [[NLTHTTPStubConnection alloc] init];
    connection.stubServer = stubServer;
    
    [connection processBodyData:[@"hoge=1" dataUsingEncoding:NSUTF8StringEncoding]];
    [connection httpResponseForMethod:@"POST" URI:@"/index"];
    GHAssertTrue(called, @"checkblockが呼ばれていない");
}
@end