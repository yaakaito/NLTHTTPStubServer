//
//  NLTStubResponseTest.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTStubResponseTest.h"
#import "NLTStubResponse.h"
#import "NLTHTTPStubResponse.h"

@implementation NLTStubResponseTest

- (void)testDataResponse {
    
    GHAssertTrue([[NLTStubResponse httpDataResponse] isKindOfClass:[NLTHTTPStubResponse class]], @"httpstubじゃないよ");
}

- (void)testFileResponse {
    
    GHAssertTrue([[NLTStubResponse httpFileResponse] isKindOfClass:[NLTHTTPStubResponse class]], @"httpstubじゃないよ");
}

@end
