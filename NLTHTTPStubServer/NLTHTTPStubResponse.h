//
//  NLTHTTPStubResponse.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NLTSConsts.h"
#import "NLTPath.h"

@interface NLTHTTPStubResponse : NSObject <NLTResponseChaining
                                           , NLTResponseHeaderPresetChaining
                                           , NLTResponseDataPresetChaining
                                           , NLTResponseHeaderCharsetChaining
                                           , NLTResponseDataCharsetChaining
                                           , NSCopying>

@property(nonatomic,strong) NLTPath   *path;
@property                   NSInteger  statusCode;
@property(nonatomic,strong) NSData    *data;
@property(nonatomic,strong) NSString  *filepath;
@property                   BOOL       shouldTimeout;
@property(nonatomic,copy)   NLTPostBodyCheckBlock postBodyCheckBlock;
@property(nonatomic,copy)   NLTPostKeyValueBodyCheckBlock postKeyValueBodyCheckBlock;
@property(nonatomic,strong) NSDictionary *httpHeaders;
@property(nonatomic,strong) NSString *httpMethod;
@property(nonatomic)        NSTimeInterval processingTimeSeconds;
@property                   BOOL external;

+ (NLTHTTPStubResponse*)stubResponse;
- (void)postBodyCheckWithBlock:(NLTPostBodyCheckBlock)block;
- (void)postKeyValueBodyCheckWithBlock:(NLTPostKeyValueBodyCheckBlock)block;

- (id)initWithHTTPStubResponse:(NLTHTTPStubResponse*)response;
@end
