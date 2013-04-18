//
//  NLTHTTPStubServer - NLTPathTest.m
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//
//  Created by: yaakaito
//

#import <GHUnitIOS/GHUnit.h>
#import "NLTPath.h"

@interface NLTPathTest : GHTestCase
{
    
}
@end

@implementation NLTPathTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (BOOL)matched:(NLTPath*)path urlPathString:(NSString*)urlPathString {
    return [path isMatchURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost%@",urlPathString]]];
}

- (void)testPathWithPathString
{
    NLTPath *path = [NLTPath pathWithPathString:@"/index"];
    GHAssertNotNil(path, @"パスが作られる");
    GHAssertEqualStrings(@"/index", path.pathString, @"pathStringがあっている");
    GHAssertNil(path.parameters, @"パラメーターはない");
    
    GHAssertTrue([self matched:path urlPathString:@"/index"], @"/indexにマッチする");
    GHAssertFalse([self matched:path urlPathString:@"/index?key=value"], @"クエリーは存在しないのでマッチしない");
}

- (void)testPathWithPathStringAndParameters
{
    NSDictionary *params = @{@"key": @"value"};
    NLTPath *path = [NLTPath pathWithPathString:@"/index" andParameters:params];
    GHAssertNotNil(path, @"パスが作られる");
    GHAssertEqualStrings(@"/index", path.pathString, @"pathStringがあっている");
    GHAssertEquals(params, path.parameters, @"パラメーターにはdictionaryが使われている");
    
    GHAssertFalse([self matched:path urlPathString:@"/index"], @"クエリーが存在しないのでマッチしない");
    GHAssertTrue([self matched:path urlPathString:@"/index?key=value"], @"クエリーが一致するのでマッチする");
    GHAssertFalse([self matched:path urlPathString:@"/index?key=yes"], @"クエリーが一致しないのでマッチしない");
    GHAssertFalse([self matched:path urlPathString:@"/index?key=value&key2=value2"], @"クエリーが多いのでマッチしない");
}

- (void)testPathWithPathStringAndManyParameters
{
    NSDictionary *params = @{@"key1": @"value1", @"key2": @"value2"};
    NLTPath *path = [NLTPath pathWithPathString:@"/index" andParameters:params];
    
    GHAssertFalse([self matched:path urlPathString:@"/index"], @"クエリーが存在しないのでマッチしない");
    GHAssertTrue([self matched:path urlPathString:@"/index?key1=value1&key2=value2"], @"クエリーが一致するのでマッチする");
    GHAssertTrue([self matched:path urlPathString:@"/index?key2=value2&key1=value1"], @"順不同でもマッチする");
    GHAssertFalse([self matched:path urlPathString:@"/index?key1=value2&key1=value2"], @"key-valueの組み合わせが違うのでマッチしない");
    GHAssertFalse([self matched:path urlPathString:@"/index?key2=value2"], @"クエリーが少ないのでマッチしない");
    GHAssertFalse([self matched:path urlPathString:@"/index?key1=value1&key2=value2&key3=value3"], @"クエリーが多いのでマッチしない");
}

- (void)testWildcard{
    NSDictionary *params = @{@"key1": [NLTPath anyValue]};
    NLTPath *path = [NLTPath pathWithPathString:@"/index" andParameters:params];
    
    GHAssertTrue([self matched:path urlPathString:@"/index?key1=hoge"], @"ワイルドカードなのでマッチする");
    GHAssertFalse([self matched:path urlPathString:@"/index?key2=hoge"], @"キー名は違うのでマッチしない");
}

- (void)testPathWithPath {
    NLTPath *first = [NLTPath pathWithPathString:@"/index" andParameters:@{@"key1": @"value1"}];
    NLTPath *second = [NLTPath pathWithPath:first andParameters:@{@"key2": @"value2"}];
    GHAssertNotNil(second, @"合成されたパスが作られる");
    GHAssertEqualStrings(first.pathString, second.pathString, @"pathStringが受け継がれる");
    GHAssertEquals(2U, [[second.parameters allKeys] count], @"合成されてパラメーターは2つ");
    GHAssertEquals(@"value1", (second.parameters)[@"key1"], @"key1 = value1");
    GHAssertEquals(@"value2", (second.parameters)[@"key2"], @"key2 = value2");
}

@end
