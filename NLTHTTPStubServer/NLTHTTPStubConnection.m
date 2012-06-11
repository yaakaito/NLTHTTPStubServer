//
//  NLTHTTPStubConnection.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//

#import "NLTHTTPStubConnection.h"
#import "NLTHTTPStubServer.h"
#import "HTTPMessage.h"

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

    if([method isEqualToString:@"POST"]){
        return YES;
    }
    
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	if([method isEqualToString:@"POST"]){
		return YES;
    }
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (void)processBodyData:(NSData *)postDataChunk
{
	[request appendData:postDataChunk];
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
    
    if ([method isEqualToString:@"POST"])
	{
        NSString *postString = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postString = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
        
        NSMutableDictionary *postKeyValues = [NSMutableDictionary dictionary];
        NSArray *keyValues = [postString componentsSeparatedByString:@"&"];
        for (NSString *keyValue in keyValues) {
            NSString *key = [[keyValue componentsSeparatedByString:@"="] objectAtIndex:0];
            NSString *value = [[keyValue componentsSeparatedByString:@"="] objectAtIndex:1];
            [postKeyValues setObject:value forKey:key];
        }
		
        NSLog(@"postString %@", postKeyValues);
	}
    
    if([response uriCheckBlock]){
        [response uriCheckBlock](url);
    }
    
    return response;
}
@end
