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
}

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

+ (id)sharedServer {
    static dispatch_once_t pred = 0;
    __strong static NLTHTTPStubServer *_sharedServer = nil;
    dispatch_once(&pred, ^{
        _sharedServer = [self stubServer];
        [_sharedServer startServer];
    });
    return _sharedServer;
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
                                                                kCFStringEncodingUTF8));

    NSURL *url = [NSURL URLWithString:encodedPathString];
    for (NSUInteger i = 0; i < [self.stubResponses count]; i++) {
        NLTHTTPStubResponse *response = (self.stubResponses)[i];
        if([response.path isMatchURL:url] && [[response httpMethod] isEqualToString:method]){
            if (!response.external) {
                [self.stubResponses removeObject:response];                
            }
            return (NLTHTTPStubResponse<HTTPResponse>*)response;
        }
    }
    return nil;
}

- (void)addStubResponse:(NLTHTTPStubResponse *)stubResponse {
    [self.stubResponses addObject:stubResponse];
}

- (BOOL)verify {
    
    NSUInteger expects = 0;
    for (NLTHTTPStubResponse *response in self.stubResponses){
        if (!response.external) {
            expects += 1;
        }
    }
    
    if (expects > 0) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%d expected responses were not invoked: %@", expects, self.stubResponses];
        return NO;
    }
    
    return YES;
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

- (id)expect {
    
    NLTHTTPStubResponse *stub = [[NLTHTTPDataStubResponse alloc] init];
    [self addStubResponse:stub];
    return stub;
}

- (id)stub{
    
    NLTHTTPStubResponse *stub = [[NLTHTTPDataStubResponse alloc] init];
    stub.external = YES;
    [self addStubResponse:stub];
    return stub;
}

@end


@implementation NLTHCurrentStubGetter
@end