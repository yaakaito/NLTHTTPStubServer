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
                                           , NLTResponseDataCharsetChaining>

@property(nonatomic,strong) NLTPath   *path;
@property                   NSInteger  statusCode;
@property(nonatomic,strong) NSData    *data;
@property(nonatomic,strong) NSString  *filepath;
@property                   BOOL       shouldTimeout;
@property(nonatomic,copy)   __httpStubResponseURICheck uriCheckBlock;
@property(nonatomic,copy)   __httpStubResponsePostBodyCheck postBodyCheckBlock;
@property(nonatomic,copy)   __httpStubResponsePostKeyValueBodyCheck postKeyValueBodyCheckBlock;
@property(nonatomic,strong) NSDictionary *httpHeaders;
@property(nonatomic,strong) NSString *httpMethod;
@property(nonatomic)        NSTimeInterval processingTimeSeconds;

+ (NLTHTTPStubResponse*)stubResponse;
- (void)URICheckWithBlock:(__httpStubResponseURICheck)block;
- (void)postBodyCheckWithBlock:(__httpStubResponsePostBodyCheck)block;
- (void)postKeyValueBodyCheckWithBlock:(__httpStubResponsePostKeyValueBodyCheck)block;
@end
