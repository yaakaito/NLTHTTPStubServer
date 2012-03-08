//
//  NLTHTTPStubResponse.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NLTStubResponse.h"

typedef BOOL(^__httpStubResponseURICheck)(NSURL *URI);

@interface NLTHTTPStubResponse : NLTStubResponse <HTTPResponse> 

@property(nonatomic,retain) NSString  *path;
@property                   NSInteger  statusCode;
@property(nonatomic,retain) NSData    *data;
@property(nonatomic,retain) NSString  *filepath;
@property(nonatomic,copy)   __httpStubResponseURICheck uriCheckBlock;

+ (NLTHTTPStubResponse*)stubResponse;
- (void)URICheckWithBlock:(__httpStubResponseURICheck)block;
@end
