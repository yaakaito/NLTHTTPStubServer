//
//  NLTHTTPStubResponseTest.m
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPStubResponseTest.h"
#import "NLTHTTPStubResponse.h"

@implementation NLTHTTPStubResponseTest

- (void)testResponseWith {
    NLTHTTPStubResponse *response = [NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                                   statusCode:200
                                                                         data:[NSData data]];
    GHAssertEqualStrings(@"/index", response.path, @"pathちがう");
    GHAssertEquals(200, response.statusCode, @"ステータスコード違う");
    GHAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
}

- (void)testHttpResponseProtocol {
    NSData *data = [@"hogehogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *response = [NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                                   statusCode:200
                                                                         data:data];
    
    GHAssertFalse([response isDone], @"まだ読み込みは完了していないはず");
    GHAssertEquals((UInt64)16, [response contentLength], @"contentLenghtが違う");
    GHAssertEquals((UInt64)0, [response offset], @"offsetはまだ0");

    NSData *readData = [response readDataOfLength:8];
    NSString *readDataString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(@"hogehoge", readDataString, @"取り出したデータの内容が違う");
    GHAssertFalse([response isDone], @"まだ読み込みは完了していないはず");
    
    GHAssertEquals((UInt64)8, [response offset], @"offsetは8になったはず");
    [response readDataOfLength:8];
    GHAssertTrue([response isDone], @"読み込みが完了しているはず");
    
    GHAssertEquals(200, [response status], @"ステータスコードが一致しない");
}

@end
