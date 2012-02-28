//
//  NLTHTTPStubServer.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubServer.h"

@implementation NLTHTTPStubServer

@synthesize stubResponses = _stubResponses;

- (id)init
{
    self = [super init];
    if (self) {
        self.stubResponses = [NSMutableArray array];
        _httpServer = [HTTPServer new];
        _httpServer.type = @"_http._tcp.";
        _httpServer.connectionClass = [NLTHTTPStubConnection class];
        _httpServer.port = [NLTHGlobalSettings globalSettings].port;
        
        [[self class] setCurrentStubServer:self];
    }
    
    return self;
}

- (void)dealloc {
    
    self.stubResponses = nil;
    
    [self stopServer];
    [_httpServer release];
    
    [super dealloc];
}

+ (NLTHTTPStubServer *)currentStubServer {
    return [[self class] __currentStubServer:[[self class] __stubGetter]];
}

+ (void)setCurrentStubServer:(NLTHTTPStubServer *)stubServer {
    [[self class] __currentStubServer:stubServer];
}

+ (NLTHTTPStubServer *)__currentStubServer:(NLTHTTPStubServer *)stubServer {
    __strong static id _sharedObject = nil;
    if(![stubServer isKindOfClass:[NLTHCurrentStubGetter class]]){
        [_sharedObject release];
        _sharedObject = [stubServer retain]; 
    }
    return _sharedObject;
}

+ (NLTHCurrentStubGetter*)__stubGetter {
    return [[[NLTHCurrentStubGetter alloc] init] autorelease];
}

+ (NLTHTTPStubServer *)stubServer {
    return [[[[self class] alloc] init] autorelease];
}

+ (NLTHGlobalSettings*)globalSettings {
    return [NLTHGlobalSettings globalSettings];
}

- (NLTHTTPStubResponse<HTTPResponse>*)responseForPath:(NSString*)path {
    for (NSUInteger i = 0; i < [self.stubResponses count]; i++) {
        NLTHTTPStubResponse *response = [self.stubResponses objectAtIndex:i];
        if([response.path isEqualToString:path]){
            [self.stubResponses removeObject:response];
            return (NLTHTTPStubResponse<HTTPResponse>*)response;
        }
    }
    return nil;
}

- (void)addStubResponse:(NLTHTTPStubResponse *)stubResponse {
    [self.stubResponses addObject:stubResponse];
}

- (BOOL)isStubEmpty {
    return [self.stubResponses count] == 0;
}

- (void)clear {
    [self.stubResponses removeAllObjects];
}

- (void)startServer {
    NSError *error;
    if(![_httpServer start:&error])
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"error starting stub server"];
    }
}

- (void)stopServer {
    [_httpServer stop];
}

@end


@implementation NLTHCurrentStubGetter
@end