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
    NSURLRequest *request;
}
@end

@implementation WithNSURLConnectionTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    [NLTHTTPStubServer globalSettings].port = 12345;
    
    server = [NLTHTTPStubServer stubServer];
    [server startServer];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    [server stopServer];
}

- (void)setUp {
    // Run before each test method
    [server clear];
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:12345/stub"];
    request = [NSURLRequest requestWithURL:url];
}

- (void)tearDown {
    // Run after each test method
    if(![server isStubEmpty]) {
        GHFail(@"stubs not empty");
    }
}

- (NSString *)toString:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id)toJSON:(NSData *)data {
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

- (void)sendAsynchronusWithCompletionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler {
    
    [self prepare];
    __weak id that = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
                               handler(res, data, err);
                               [that notify:kGHUnitWaitStatusSuccess];
                           }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

- (void)testMostSimply {
    
    NSData *data = [@"HelloWorld" dataUsingEncoding:NSUTF8StringEncoding];
    [[[server stub] forPath:@"/stub"] andPlainResponse:data];
    
    __weak id that = self;
    [self sendAsynchronusWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        GHAssertNil(error, @"");
        GHAssertEqualStrings([that toString:data], @"HelloWorld", @"");
    }];
}

- (void)testWithFile {
    
    [[[server stub] forPath:@"/stub"] andJSONResponseResource:@"fake" ofType:@"json"];
    
    __weak id that = self;
    [self sendAsynchronusWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        GHAssertNil(error, @"");
        NSDictionary *JSON = [that toJSON:data];
        GHAssertEqualStrings(JSON[@"fake"], @"dummy", @"");
    }];
}

@end
