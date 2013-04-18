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
#import "NLTHTTPDataStubResponse.h"

@implementation NLTStubResponseTest

- (void)testDataResponse {
    
    GHAssertTrue([[NLTStubResponse httpDataResponse] isKindOfClass:[NLTHTTPStubResponse class]], @"httpstubじゃないよ");
    GHAssertTrue([[NLTStubResponse httpDataResponse] isKindOfClass:[NLTHTTPDataStubResponse class]], @"httpdatastubじゃないよ");
}

@end
