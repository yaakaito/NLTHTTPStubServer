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


- (id)forPath:(NSString *)path_ {
    self.path = path_;
    return self;
}

- (id)andResponse:(NSData *)data_ {
    self.data = data_;
    return self;
}

- (id)andStatusCode:(NSInteger)statusCode_ {
    self.statusCode = statusCode_;
    return self;
}

- (id)andCheckURI:(__httpStubResponseURICheck)checkBlock_ {
    self.uriCheckBlock = checkBlock_;
    return self;
}
@end
