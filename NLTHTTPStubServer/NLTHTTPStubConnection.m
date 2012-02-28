//
//  NLTHTTPStubConnection.m
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
