//
//  NLTStubResponse.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTStubResponse.h"
#import "NLTHTTPStubResponse.h"

@implementation NLTStubResponse
+ (id)httpDataResponse {
    
    return [NLTHTTPStubResponse stubResponse];
}

+ (id)httpFileResponse {
    
    return [NLTHTTPStubResponse stubResponse];
}

@end
