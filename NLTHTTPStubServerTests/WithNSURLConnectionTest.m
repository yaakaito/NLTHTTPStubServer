//
//  NLTHTTPStubServer - WithNSURLConnectionTest.m
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
//  Created by: kazuma.ukyo
//

#import <GHUnitIOS/GHUnit.h>
#import "NLTHTTPStubServer.h"

@interface WithNSURLConnectionTest : GHAsyncTestCase
{
    NLTHTTPStubServer *server; 
}
@end

@implementation WithNSURLConnectionTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    server = [NLTHTTPStubServer sharedServer];
}

- (void)setUp {
    // Run before each test method
    [server clear];
}

- (void)tearDown {
    // Run after each test method
    if(![server verify]) {
        GHFail(@"stubs not empty");
    }
}

- (NSString *)toString:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id)toJSON:(NSData *)data {
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

- (void)testWithURLString:(NSString *)urlString andCompletionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler {
    [self prepare];
    __weak id that = self;

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
                               handler(res, data, err);
                               [that notify:kGHUnitWaitStatusSuccess];
                           }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

- (void)testWithCompletionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler {
    
    [self testWithURLString:@"http://localhost:12345/stub" andCompletionHandler:handler];
}

- (void)testMostSimply {
    
    NSData *data = [@"RESPONSE" dataUsingEncoding:NSUTF8StringEncoding];
    [[[server expect] forPath:@"/stub"] andPlainResponse:data];
    
    __weak id that = self;
    [self testWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        GHAssertNil(error, nil);
        GHAssertEqualStrings([that toString:data], @"RESPONSE", nil);
    }];

    [server verify];
}

- (void)testJSONObject {

    [[[server expect] forPath:@"/stub"] andJSONResponseObject:@{ @"RESPONSE" : @"BODY" }];

    __weak id that = self;
    [self testWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        GHAssertNil(error, nil);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        GHAssertEqualStrings(JSON[@"RESPONSE"], @"BODY", nil);
    }];

    [server verify];
}


- (void)testWithNLTPathAndGavenGetParameters {

    [[server expect] forPath:[NLTPath pathWithPathString:@"/stub" andParameters:@{
            @"k1" : @"v1",
            @"k2" : @"v2",
            @"w" : [NLTPath anyValue]
    }]];

    [self testWithURLString:@"http://localhost:12345/stub?k1=v1&k2=v2&w=willlllld"
       andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {}];

    [server verify];
}

- (void)testExternalStubResponse {

    [[server stub] forPath:@"/stub"];
    [[server expect] forPath:@"/expect"];
    [self testWithURLString:@"http://localhost:12345/stub"
       andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {}];
    [self testWithURLString:@"http://localhost:12345/expect"
       andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {}];
    [self testWithURLString:@"http://localhost:12345/stub"
       andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {}];

    [server verify];
}

- (void)testWithFile {
    
    [[[server expect] forPath:@"/stub"] andJSONResponseResource:@"fake" ofType:@"json"];
    
    __weak id that = self;
    [self testWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        GHAssertNil(error, nil);
        NSDictionary *JSON = [that toJSON:data];
        GHAssertEqualStrings(JSON[@"fake"], @"dummy", nil);
    }];

    [server verify];
}

- (void)testNotFound {

    [[[server expect] forPath:@"/stub"] andStatusCode:404];

    [self testWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *URLResponse = (NSHTTPURLResponse *)response;
        GHAssertEquals([URLResponse statusCode], 404, nil);
    }];

    [server verify];
}

- (void)testRequestTwice {

    [[[server expect] forPath:@"/one"] andJSONResponseResource:@"fake" ofType:@"json"];
    [[[server expect] forPath:@"/two"] andJSONResponseResource:@"fake" ofType:@"json"];

    __weak id that = self;
    [self testWithURLString:@"http://localhost:12345/one"
       andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
           NSDictionary *JSON = [that toJSON:data];
           GHAssertEqualStrings(JSON[@"fake"], @"dummy", nil);
       }];
    [self testWithURLString:@"http://localhost:12345/two"
       andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
           NSDictionary *JSON = [that toJSON:data];
           GHAssertEqualStrings(JSON[@"fake"], @"dummy", nil);
       }];

    [server verify];
}

- (void)testDuplicate {

    [[[server expect] forPath:@"/stub"] andPlainResponse:[@"ONE" dataUsingEncoding:NSUTF8StringEncoding]];
    [[[server expect] forPath:@"/stub"] andPlainResponse:[@"TWO" dataUsingEncoding:NSUTF8StringEncoding]];

    __weak id that = self;
    [self testWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        GHAssertEqualStrings([that toString:data], @"ONE", nil);
    }];

    [self testWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        GHAssertEqualStrings([that toString:data], @"TWO", nil);
    }];

    [server verify];
}

- (void)testProcessingTime {

    [[[[server expect] forPath:@"/stub"] andPlainResponse:[@"RESPONSE" dataUsingEncoding:NSUTF8StringEncoding]] andProcessingTime:1.5f];

    NSDate *t = [NSDate date];
    [self testWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {}];

    GHAssertTrue(-[t timeIntervalSinceNow] > 1.4, nil);
}

- (void)testWithHTTPMethod:(NSString *)method
            POSTBodyString:(NSString *)bodyString
      andCompletionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler {

    NSURL *url = [NSURL URLWithString:@"http://localhost:12345/stub"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];

    [self prepare];
    __weak id that = self;

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
                               handler(res, data, err);
                               [that notify:kGHUnitWaitStatusSuccess];
                           }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0f];
}

- (void)testPOSTRequest {

    __weak id that = self;
    __block BOOL called = NO;
    [[[[server expect] forPath:@"/stub" HTTPMethod:@"POST"] andPlainResponse:[@"RESPONSE" dataUsingEncoding:NSUTF8StringEncoding]] andCheckPostBody:^(NSData *postBody) {
        NSString *postBodyString = [that toString:postBody];
        GHAssertEqualStrings(postBodyString, @"POST_BODY", nil);
        called = YES;
    }];

    [self testWithHTTPMethod:@"POST"
              POSTBodyString:@"POST_BODY"
        andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            GHAssertEqualStrings([that toString:data], @"RESPONSE", nil);
        }];

    GHAssertTrue(called, nil);
    [server verify];

}

- (void)testPUTRequest {

    __weak id that = self;
    __block BOOL called = NO;
    [[[[server expect] forPath:@"/stub" HTTPMethod:@"PUT"] andPlainResponse:[@"RESPONSE" dataUsingEncoding:NSUTF8StringEncoding]] andCheckPostBody:^(NSData *postBody) {
        NSString *postBodyString = [that toString:postBody];
        GHAssertEqualStrings(postBodyString, @"POST_BODY", nil);
        called = YES;
    }];

    [self testWithHTTPMethod:@"PUT"
              POSTBodyString:@"POST_BODY"
        andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            GHAssertEqualStrings([that toString:data], @"RESPONSE", nil);
        }];

    GHAssertTrue(called, nil);
    [server verify];

}

- (void)testDELETERequest {
    [[[server expect] forPath:@"/stub" HTTPMethod:@"DELETE"] andPlainResponse:[@"RESPONSE" dataUsingEncoding:NSUTF8StringEncoding]];

    __weak id that = self;
    [self testWithHTTPMethod:@"DELETE"
              POSTBodyString:nil
        andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            GHAssertEqualStrings([that toString:data], @"RESPONSE", nil);
        }];

    [server verify];
}
@end
