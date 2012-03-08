//
//  NLTStubResponse.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTStubResponse.h"
#import "NLTHTTPStubResponse.h"
#import "NLTHTTPDataStubResponse.h"
#import "NLTHTTPFileStubResponse.h"

@implementation NLTStubResponse
+ (id)httpDataResponse {
    
    return [NLTHTTPDataStubResponse dataStubResponse];
}

+ (id)httpFileResponse {
    
    return [NLTHTTPFileStubResponse fileStubResponse];
}

@end
