//
//  NLTHTTPStubServerWithAFNetwrokingTest.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo on 12/04/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPStubServerWithAFNetwrokingTest.h"
#import "AFNetworking.h"

@implementation NLTHTTPStubServerWithAFNetwrokingTest

- (void)setUpClass {
    [NLTHTTPStubServer globalSettings].port = 12345;
    
    server = [[NLTHTTPStubServer stubServer] retain];
    [server startServer];
}

- (void)tearDownClass {
    
    [server stopServer];
    [server release];
}

- (void)setUp {
    [server clear];
}

- (void)tearDown {
    if(![server isStubEmpty]) {
        GHFail(@"stubs not empty");
    }
}

- (void)testJSONResponse {
    
    NSData *json = [@"{\"status\":\"ok\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [[[server stub] forPath:@"/index.json"] andJSONResponse:json];
    
    [self prepare];
    NSURL *url = [NSURL URLWithString:@"http://localhost:12345/index.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        GHAssertEqualStrings(@"ok", [JSON objectForKey:@"status"], @"status = ok");
        [self notify:kGHUnitWaitStatusSuccess];
    } failure:nil];
    [operation start];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0f];
}
@end
