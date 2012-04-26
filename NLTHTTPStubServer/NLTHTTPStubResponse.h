//
//  NLTHTTPStubResponse.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NLTSConsts.h"
#import "NLTStubResponse.h"

@interface NLTHTTPStubResponse : NLTStubResponse <NLTResponseChaining
                                                , NLTResponseHeaderPresetChaining
                                                , NLTResponseDataPresetChaining
                                                , NLTResponseHeaderCharsetChaining
                                                , NLTResponseDataCharsetChaining>

@property(nonatomic,retain) NSString  *path;
@property                   NSInteger  statusCode;
@property(nonatomic,retain) NSData    *data;
@property(nonatomic,retain) NSString  *filepath;
@property                   BOOL       shouldTimeout;
@property(nonatomic,copy)   __httpStubResponseURICheck uriCheckBlock;
@property(nonatomic,retain) NSDictionary *httpHeaders;

+ (NLTHTTPStubResponse*)stubResponse;
- (void)URICheckWithBlock:(__httpStubResponseURICheck)block;
@end
