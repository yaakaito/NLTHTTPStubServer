//
//  NLTHTTPStubServerTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubServerTest.h"
#import "NLTHTTPStubServer.h"
#import "NLTHTTPDataStubResponse.h"

@implementation NLTHTTPStubServerTest

- (void)tearDown {
    [NLTHTTPStubServer setCurrentStubServer:nil];
}


- (void)testCurrentStubServerAccessser {
    
    GHAssertNil([NLTHTTPStubServer currentStubServer], @"まだサーバーは作られていない");
    NLTHTTPStubServer *server1 = [NLTHTTPStubServer stubServer];
    [NLTHTTPStubServer setCurrentStubServer:server1];
    GHAssertEqualObjects(server1, [NLTHTTPStubServer currentStubServer], @"登録したはずのオブジェクトと一致しない");
    NLTHTTPStubServer *server2 = [NLTHTTPStubServer stubServer];
    [NLTHTTPStubServer setCurrentStubServer:server2];
    
    GHAssertEqualObjects(server2, [NLTHTTPStubServer currentStubServer], @"登録したはずのオブジェクトと一致しないまたは上書きされていない");
    GHAssertNotEqualObjects(server1, [NLTHTTPStubServer currentStubServer], @"以前のものが取得されている");
}

- (void)testIsStubEmpty {
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    GHAssertTrue([server verify], @"何もないので空のはずだが");
    [server addStubResponse: [[NLTHTTPDataStubResponse alloc] init]];
    GHAssertFalse([server verify], @"スタブがあるので空ではないはず");
    
}

- (void)testClear {
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    [server addStubResponse:[[NLTHTTPDataStubResponse alloc] init]];
    GHAssertFalse([server verify], @"スタブがあるので空ではないはず");
    [server clear];
    GHAssertTrue([server verify], @"何もないので空のはずだが");

}

- (void)testChainingStub {
    
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    NLTHTTPStubResponse *response = [server expect];
    GHAssertEquals(1U, [server.stubResponses count], @"スタブが1つ作られるはず");
    GHAssertEqualObjects(response, (server.stubResponses)[0], @"オブジェクトが一致しない");
    
    [server expect];
    GHAssertEquals(2U, [server.stubResponses count], @"スタブが2つ作られるはず");
}

- (void)testResponseForPath {
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:nil], @"まだスタブされてない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@""], @"まだスタブされてない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"GET"], @"まだスタブされてない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"POST"], @"まだスタブされてない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"PUT"], @"まだスタブされてない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"DELETE"], @"まだスタブされてない");
    
    NLTHTTPStubResponse *get_index = [[[NLTHTTPDataStubResponse alloc] init] forPath:@"/index" HTTPMethod:@"GET"];
    [server addStubResponse:get_index];
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:nil], @"HTTPMethodがnilだと問答無用で返せない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@""], @"HTTPMethodが空文字列だと問答無用で返せない");
    GHAssertEqualObjects(get_index, [server responseForPath:@"/index" HTTPMethod:@"GET"], @"スタブされているので返せるはず");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"GET"], @"スタブは一度返すと消費されてしまうので次はもう返ってこない");
    [server addStubResponse:get_index];
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"POST"], @"メソッドが違うので返せない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"PUT"], @"メソッドが違うので返せない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"DELETE"], @"メソッドが違うので返せない");
    [server clear];
    GHAssertTrue([server verify], @"次のテストの前に状態を空にしておく");
    
    NLTHTTPStubResponse *post_index = [[[NLTHTTPStubResponse alloc] init] forPath:@"/index" HTTPMethod:@"POST"];
    [server addStubResponse:post_index];
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:nil], @"HTTPMethodがnilだと問答無用で返せない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@""], @"HTTPMethodが空文字列だと問答無用で返せない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"GET"], @"メソッドが違うので返せない");
    GHAssertEqualObjects(post_index, [server responseForPath:@"/index" HTTPMethod:@"POST"], @"スタブされているので返せるはず");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"POST"], @"スタブは一度返すと消費されてしまうので次はもう返ってこない");
    [server addStubResponse:post_index];
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"PUT"], @"メソッドが違うので返せない");
    GHAssertNil([server responseForPath:@"/index" HTTPMethod:@"DELETE"], @"メソッドが違うので返せない");
    [server clear];
    GHAssertTrue([server verify], @"次のテストの前に状態を空にしておく");
}

- (void)testResponseForPathWithQueryString {
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    NLTHTTPStubResponse *get_index_query1 = [[[NLTHTTPStubResponse alloc] init] forPath:@"/index?foo=bar" HTTPMethod:@"GET"];
    [server addStubResponse:get_index_query1];
    GHAssertNil([server responseForPath:@"/index?foo=bar" HTTPMethod:@"GET"], @"クエリストリングを指定しても返ってくる");
}

- (void)testResponseForPathForContainsMultibyteText {
    NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)@"マルチバイト文字列",
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 );
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    [server addStubResponse:[[NLTHTTPDataStubResponse alloc] init]];
    NLTHTTPStubResponse *response =[[NLTHTTPDataStubResponse alloc] init];
    response.statusCode = 200;
    response.path = [NLTPath pathWithPathString:[NSString stringWithFormat:@"/index/%@", encodedString]];
    response.data = [NSData data];
    [server addStubResponse:response];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/index/%@", encodedString]];
    NLTHTTPStubResponse *testedResponse = [server responseForPath:[url relativePath] HTTPMethod:@"GET"];
    
    GHAssertNotNil(testedResponse, @"responseはあるはず");
    NSString *encodedPath = [NSString stringWithFormat:@"/index/%@", encodedString];
    GHAssertEqualStrings(encodedPath, testedResponse.path.pathString, @"/index/マルチバイト文字列のstubを取得できるはずだが");
}
@end
