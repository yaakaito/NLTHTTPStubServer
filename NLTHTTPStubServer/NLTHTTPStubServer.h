//
//  NLTHTTPStubServer.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo on 12/02/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"

#import "NLTHTTPStubResponse.h"
#import "NLTHGlobalSettings.h"


@interface NLTHTTPStubServer : NSObject {
    HTTPServer *_httpServer;
    NSMutableArray *_stubResponses;
}
@property(nonatomic,readonly) NSArray *stubResponses;
+ (NLTHTTPStubServer*)currentStubServer;
+ (void)setCurrentStubServer:(NLTHTTPStubServer*)stubServer;
+ (NLTHTTPStubServer*)__currentStubServer:(NLTHTTPStubServer*)stubServer;
+ (NLTHTTPStubServer*)stubServer;
+ (NLTHGlobalSettings*)globalSettings;
- (void)addStubResponse:(NLTHTTPStubResponse*)stubResponse;
- (BOOL)isStubEmpty;
@end
