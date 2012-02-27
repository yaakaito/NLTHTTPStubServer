//
//  NLTHTTPStubResponse.m
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPStubResponse.h"

@implementation NLTHTTPStubResponse
@synthesize path        = _path;
@synthesize statusCode  = _statusCode;
@synthesize data        = _data;

+ (NLTHTTPStubResponse*)stubResponseWithPath:(NSString *)path
                                  statusCode:(NSInteger)statusCode
                                        data:(NSData *)data {
    NLTHTTPStubResponse *response = [[NLTHTTPStubResponse alloc] init];
    response.path = path;
    response.statusCode = statusCode;
    response.data = data;
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
	offset = (NSUInteger)offsetParam;
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
