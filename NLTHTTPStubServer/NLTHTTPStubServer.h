//
//  NLTHTTPStubServer.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HTTPServer.h"
#import "NLTSConsts.h"
#import "NLTHGlobalSettings.h"
#import "NLTHTTPStubConnection.h"
#import "NLTHTTPStubResponse.h"

@class NLTHCurrentStubGetter;

@interface NLTHTTPStubServer : NSObject<NLTServerChaining>

@property(nonatomic,strong) NSMutableArray *stubResponses;

+ (id)sharedServer;

+ (NLTHTTPStubServer*)currentStubServer;
+ (void)setCurrentStubServer:(NLTHTTPStubServer*)stubServer;

+ (NLTHTTPStubServer*)stubServer;

+ (NLTHGlobalSettings*)globalSettings;

- (void)addStubResponse:(NLTHTTPStubResponse*)stubResponse;
- (void)verify;
- (void)clear;

- (void)startServer;
- (void)stopServer;

- (NLTHTTPStubResponse<HTTPResponse>*)responseForPath:(NSString*)path HTTPMethod:(NSString*)method;
@end

@interface NLTHCurrentStubGetter : NLTHTTPStubServer
@end