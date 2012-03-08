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
    
    NSString *relativePath = [[NSURL URLWithString:path] relativePath];
    
    if(!self.stubServer){
        self.stubServer = [NLTHTTPStubServer currentStubServer];
    }
    
    NLTHTTPStubResponse<HTTPResponse> *response = [self.stubServer responseForPath:relativePath];
    if(!response){
        [NSException raise:NSInternalInconsistencyException
                    format:@"unstubed request invoked (path=%@)", path];
    }
    
    return response;
}
@end
