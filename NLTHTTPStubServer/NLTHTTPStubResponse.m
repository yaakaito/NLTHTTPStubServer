//
//  NLTHTTPStubResponse.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubResponse.h"

@implementation NLTHTTPStubResponse
{
    
    NSInteger _offset;
}

@synthesize path        = _path;
@synthesize statusCode  = _statusCode;
@synthesize data        = _data;

+ (NLTHTTPStubResponse *)stubResponse {
    return [[[NLTHTTPStubResponse alloc] init] autorelease];
}

+ (NLTHTTPStubResponse*)stubResponseWithPath:(NSString *)path
                                  statusCode:(NSInteger)statusCode
                                        data:(NSData *)data {
    NLTHTTPStubResponse *response = [[NLTHTTPStubResponse alloc] init];
    response.path = path;
    response.statusCode = statusCode;
    response.data = data;
    
    return [response autorelease];
}

- (void)dealloc {
    
    self.path = nil;
    self.data = nil;
    
    [super dealloc];
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
@end
