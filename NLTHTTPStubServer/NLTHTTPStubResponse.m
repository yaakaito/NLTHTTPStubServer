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
@synthesize uriCheckBlock;

+ (NLTHTTPStubResponse *)stubResponse {
    return [[[NLTHTTPStubResponse alloc] init] autorelease];
}

- (void)dealloc {
    
    self.path = nil;
    self.data = nil;
    self.filepath = nil;
    
    [super dealloc];
}

- (void)URICheckWithBlock:(__httpStubResponseURICheck)block {
    self.uriCheckBlock = block;
}
@end
