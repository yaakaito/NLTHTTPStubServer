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
