//
//  NLTHTTPStubServer.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HTTPServer.h"

#import "NLTHGlobalSettings.h"
#import "NLTHTTPStubConnection.h"
#import "NLTHTTPStubResponse.h"

@class NLTHCurrentStubGetter;

@interface NLTHTTPStubServer : NSObject {
    HTTPServer *_httpServer;
    NSMutableArray *_stubResponses;
}

@property(nonatomic,retain) NSMutableArray *stubResponses;

+ (NLTHTTPStubServer*)currentStubServer;
+ (void)setCurrentStubServer:(NLTHTTPStubServer*)stubServer;
+ (NLTHTTPStubServer*)__currentStubServer:(NLTHTTPStubServer*)stubServer;
+ (NLTHCurrentStubGetter*)__stubGetter;

+ (NLTHTTPStubServer*)stubServer;

+ (NLTHGlobalSettings*)globalSettings;

- (void)addStubResponse:(NLTHTTPStubResponse*)stubResponse;
- (BOOL)isStubEmpty;
- (void)clear;

- (void)startServer;
- (void)stopServer;

- (NLTHTTPStubResponse<HTTPResponse>*)responseForPath:(NSString*)path;
@end

@interface NLTHCurrentStubGetter : NLTHTTPStubServer
@end