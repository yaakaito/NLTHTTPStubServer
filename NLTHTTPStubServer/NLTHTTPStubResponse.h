//
//  NLTHTTPStubResponse.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NLTStubResponse.h"

@interface NLTHTTPStubResponse : NLTStubResponse <HTTPResponse> 

@property(nonatomic,retain) NSString *path;
@property NSInteger                   statusCode;
@property(nonatomic,retain) NSData   *data;

+ (NLTHTTPStubResponse*)stubResponse;
+ (NLTHTTPStubResponse*)stubResponseWithPath:(NSString *)path
                                  statusCode:(NSInteger)statusCode
                                        data:(NSData *)data;
@end
