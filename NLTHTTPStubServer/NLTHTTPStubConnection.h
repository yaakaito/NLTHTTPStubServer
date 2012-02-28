//
//  NLTHTTPStubConnection.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HTTPConnection.h"
#import "NLTHTTPStubResponse.h"

@class NLTHTTPStubServer;

@interface NLTHTTPStubConnection : HTTPConnection
@property(nonatomic,assign) NLTHTTPStubServer *stubServer; 
@end
