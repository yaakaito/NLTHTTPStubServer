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
    
    if([method isEqualToString:@"PUT"]){
        return YES;
    }
    
    if([method isEqualToString:@"DELETE"]){
        return YES;
    }
    
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	if([method isEqualToString:@"POST"]){
		return YES;
    }
	
    if([method isEqualToString:@"PUT"]){
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
    
    if(!self.stubServer){
        self.stubServer = [NLTHTTPStubServer currentStubServer];
    }
    
    NLTHTTPStubResponse<HTTPResponse> *response = [self.stubServer responseForPath:path HTTPMethod:method];
    if(!response){
        [NSException raise:NSInternalInconsistencyException
                    format:@"unstubed request invoked (path=%@)", path];
    }
    
    if (response.processingTimeSeconds > 0.0f) {
        [NSThread sleepForTimeInterval:response.processingTimeSeconds];
    }
    
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"])
	{
        NSString *postString = nil;
		
		NSData *postData = [request body];
        if([response postBodyCheckBlock]) {
            [response postBodyCheckBlock](postData);
        }
		if([response postKeyValueBodyCheckBlock]){
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
            [response postKeyValueBodyCheckBlock](postKeyValues);		
        }
	}
    
    if([response uriCheckBlock]){
        [response uriCheckBlock](url);
    }
    
    return response;
}
@end
