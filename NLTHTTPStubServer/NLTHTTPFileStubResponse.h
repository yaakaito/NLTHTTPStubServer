//
//  NLTHTTPFileStubResponse.h
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLTHTTPStubResponse.h"

@interface NLTHTTPFileStubResponse : NLTHTTPStubResponse <HTTPResponse,NSCopying>
+ (NLTHTTPFileStubResponse*)fileStubResponse;
@end
