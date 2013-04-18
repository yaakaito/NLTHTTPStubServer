//
//  NLTHTTPStubServer.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubServer.h"
#import "NLTHTTPDataStubResponse.h"
#import "NLTPath.h"

@implementation NLTHTTPStubServer {
    HTTPServer *_httpServer;
    NSMutableArray *_stubResponses;
}


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
    
    
    [self stopServer];
    
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
        _sharedObject = stubServer; 
    }
    return _sharedObject;
}

+ (NLTHCurrentStubGetter*)__stubGetter {
    return [[NLTHCurrentStubGetter alloc] init];
}

+ (NLTHTTPStubServer *)stubServer {
    return [[[self class] alloc] init];
}

+ (NLTHGlobalSettings*)globalSettings {
    return [NLTHGlobalSettings globalSettings];
}

- (NLTHTTPStubResponse<HTTPResponse>*)responseForPath:(NSString*)path HTTPMethod:(NSString *)method {
    NSString *encodedPathString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                       NULL,
                                                                                       (CFStringRef)path,
                                                                                       NULL,
                                                                                       NULL,
                                                                                       kCFStringEncodingUTF8 ));

    NSURL *url = [NSURL URLWithString:encodedPathString];
    for (NSUInteger i = 0; i < [self.stubResponses count]; i++) {
        NLTHTTPStubResponse *response = (self.stubResponses)[i];
        if([response.path isMatchURL:url] && [[response httpMethod] isEqualToString:method]){
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

- (id)stub {
    
    NLTHTTPStubResponse *stub = [[NLTHTTPDataStubResponse alloc] init];
    [self addStubResponse:stub];
    return stub;
}

@end


@implementation NLTHCurrentStubGetter
@end