//
//  NLTHTTPStubResponse.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubResponse.h"

@implementation NLTHTTPStubResponse

@synthesize path;
@synthesize statusCode;
@synthesize data;
@synthesize filepath;
@synthesize shouldTimeout;
@synthesize uriCheckBlock;
@synthesize httpHeaders;

+ (NLTHTTPStubResponse *)stubResponse {
    return [[[NLTHTTPStubResponse alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if(self){
        self.statusCode = 200;
        self.shouldTimeout = NO;
        self.httpHeaders = [NSDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    
    self.path = nil;
    self.data = nil;
    self.filepath = nil;
    self.httpHeaders = nil;
    
    [super dealloc];
}

- (void)URICheckWithBlock:(__httpStubResponseURICheck)block {
    self.uriCheckBlock = block;
}

@end
