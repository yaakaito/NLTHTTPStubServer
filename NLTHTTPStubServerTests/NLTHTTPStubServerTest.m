//
//  NLTHTTPStubServerTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubServerTest.h"
#import "NLTHTTPStubServer.h"

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

- (void)testStubGetter {
    NLTHTTPStubServer *getter = [NLTHTTPStubServer __stubGetter];
    GHAssertTrue([getter isKindOfClass:[NLTHCurrentStubGetter class]], @"このクラスは取得用のクラスじゃない");
}

- (void)testIsStubEmpty {
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    GHAssertTrue([server isStubEmpty], @"何もないので空のはずだが");
    [server addStubResponse: [NLTStubResponse httpDataResponse]];
    GHAssertFalse([server isStubEmpty], @"スタブがあるので空ではないはず");
    
}

- (void)testClear {
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    [server addStubResponse:[NLTStubResponse httpDataResponse]];
    GHAssertFalse([server isStubEmpty], @"スタブがあるので空ではないはず");
    [server clear];
    GHAssertTrue([server isStubEmpty], @"何もないので空のはずだが");

}

- (void)testChainingStub {
    
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    NLTHTTPStubResponse *response = [server stub];
    GHAssertEquals(1U, [server.stubResponses count], @"スタブが1つ作られるはず");
    GHAssertEqualObjects(response, [server.stubResponses objectAtIndex:0], @"オブジェクトが一致しない");
    
    [server stub];
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
    
    NLTHTTPStubResponse *get_index = [[NLTHTTPStubResponse httpDataResponse] forPath:@"/index" HTTPMethod:@"GET"];
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
    GHAssertTrue([server isStubEmpty], @"次のテストの前に状態を空にしておく");
    
    NLTHTTPStubResponse *post_index = [[NLTHTTPStubResponse httpDataResponse] forPath:@"/index" HTTPMethod:@"POST"];
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
    GHAssertTrue([server isStubEmpty], @"次のテストの前に状態を空にしておく");
}

- (void)testResponseForPathForContainsMultibyteText {
    NSString *encodedString = [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)@"マルチバイト文字列",
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 ) autorelease];
    NLTHTTPStubServer *server = [NLTHTTPStubServer stubServer];
    [server addStubResponse:[NLTStubResponse httpDataResponse]];
    NLTHTTPStubResponse *response = [NLTStubResponse httpDataResponse];
    response.statusCode = 200;
    response.path = [NSString stringWithFormat:@"/index/%@", encodedString];
    response.data = [NSData data];
    [server addStubResponse:response];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/index/%@", encodedString]];
    NLTHTTPStubResponse *testedResponse = [server responseForPath:[url relativePath] HTTPMethod:@"GET"];
    
    GHAssertNotNil(testedResponse, @"responseはあるはず");
    NSString *encodedPath = [NSString stringWithFormat:@"/index/%@", encodedString];
    GHAssertEqualStrings(encodedPath, testedResponse.path, @"/index/マルチバイト文字列のstubを取得できるはずだが");
}
@end
