//
//  NLTHTTPFileStubResponseTest.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPFileStubResponseTest.h"
#import "NLTHTTPFileStubResponse.h"

@implementation NLTHTTPFileStubResponseTest

- (void)testSetFilePath {

    NLTHTTPFileStubResponse *stub = [NLTHTTPFileStubResponse fileStubResponse];
    GHAssertThrows([stub setFilepath:@"hogehoge"], @"存在しないファイルなのでexception飛ぶはずだけど");
    stub = [NLTHTTPFileStubResponse fileStubResponse];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                     ofType:@"txt"];
    GHAssertNoThrow([stub setFilepath:path], @"存在するのでexceptionは飛ばないはず");
    GHAssertEquals((UInt64)16, [stub contentLength], @"length=%d", [stub contentLength]);
}

- (void)testHttpResponseProtocol {
    NLTHTTPFileStubResponse *response = [NLTHTTPFileStubResponse fileStubResponse];
    response.statusCode = 200;
    response.path = @"/index";
    response.filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                         ofType:@"txt"];
    
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
