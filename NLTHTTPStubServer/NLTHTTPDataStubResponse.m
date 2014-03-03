//
//  NLTHTTPDataStubResponse.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPDataStubResponse.h"

@implementation NLTHTTPDataStubResponse
{
    NSInteger _offset;
}

+ (id)dataStubResponse {
    return [[NLTHTTPDataStubResponse alloc] init];
}

+ (id)dataStubResponseWithDataStubResponse:(NLTHTTPDataStubResponse*)response {
    return [[NLTHTTPDataStubResponse alloc] initWithHTTPStubResponse:response];
}

- (UInt64)contentLength
{
	return (UInt64)[self.data length];
}

- (UInt64)offset
{
	return _offset;
}

- (void)setOffset:(UInt64)offsetParam
{	
	_offset = (NSUInteger)offsetParam;
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParameter
{
	NSUInteger remaining = [self.data length] - _offset;
	NSUInteger length = lengthParameter < remaining ? lengthParameter : remaining;
	
	void *bytes = (void *)([self.data bytes] + _offset);
	
	_offset += length;
    
	return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:NO];
}

- (BOOL)isDone
{
	return (_offset == [self.data length]);
}

- (NSInteger)status {
    return self.statusCode;
}

- (BOOL)delayResponseHeaders {
    return self.shouldTimeout;
}

@end
