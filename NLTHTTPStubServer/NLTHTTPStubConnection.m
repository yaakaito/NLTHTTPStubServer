//
//  NLTHTTPStubConnection.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//

#import "NLTHTTPStubConnection.h"
#import "NLTHTTPStubServer.h"

@implementation NLTHTTPStubConnection
@synthesize stubServer;

- (id)init
{
    self = [super initWithAsyncSocket:nil configuration:nil];
    if (self) {
        
    }
    return self;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {

    [super supportsMethod:method atPath:path];
    
	if ([method isEqualToString:@"GET"]) {
		return YES;
    }
	
	if ([method isEqualToString:@"HEAD"]) {
		return YES;
    }

    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
    
	return NO;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    
    NSURL *url = [NSURL URLWithString:path];
    NSString *relativePath = [url relativePath];
    
    if(!self.stubServer){
        self.stubServer = [NLTHTTPStubServer currentStubServer];
    }
    
    NLTHTTPStubResponse<HTTPResponse> *response = [self.stubServer responseForPath:relativePath];
    if(!response){
        [NSException raise:NSInternalInconsistencyException
                    format:@"unstubed request invoked (path=%@)", path];
    }
    
    if([response uriCheckBlock]){
        [response uriCheckBlock](url);
    }
    
    return response;
}
@end
