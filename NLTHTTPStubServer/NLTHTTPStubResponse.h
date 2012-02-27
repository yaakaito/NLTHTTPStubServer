//
//  NLTHTTPStubResponse.h
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLTHTTPStubResponse : NSObject
+ (NLTHTTPStubResponse*)stubResponseWithPath:(NSString *)path
                                  statusCode:(NSUInteger)statusCode
                                        data:(NSData *)data;
@end
