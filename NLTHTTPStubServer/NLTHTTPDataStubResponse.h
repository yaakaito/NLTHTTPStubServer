//
//  NLTHTTPDataStubResponse.h
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaHTTPServer/HTTPResponse.h>
#import "NLTHTTPStubResponse.h"
#import "NLTSConsts.h"

@interface NLTHTTPDataStubResponse : NLTHTTPStubResponse <HTTPResponse> 
+ (id)dataStubResponse;
+ (id)dataStubResponseWithDataStubResponse:(NLTHTTPDataStubResponse*)response;
@end
