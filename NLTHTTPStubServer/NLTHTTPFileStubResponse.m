//
//  NLTHTTPFileStubResponse.m
//  NLTHTTPStubServer
//
//  Created by  on 12/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPFileStubResponse.h"

#import <unistd.h>
#import <fcntl.h>

#define NULL_FD  -1

@implementation NLTHTTPFileStubResponse
{
    NSString *_filepath;
	UInt64 _fileLength;
	UInt64 _fileOffset;
	
	BOOL _aborted;
	
	int _fileFD;
	void *_buffer;
	NSUInteger _bufferSize;
}

- (id)init {
    
    self = [super init];
    if(self){
        _fileFD = NULL_FD;
        _fileOffset = 0;
		_aborted = NO;
		
    }
    return self;
}

+ (NLTHTTPFileStubResponse *)fileStubResponse {
    return [[[NLTHTTPFileStubResponse alloc] init] autorelease];
}

+ (NLTHTTPFileStubResponse*)fileStubResponseWithFileStubResponse:(NLTHTTPFileStubResponse*)response {
    
    NLTHTTPFileStubResponse *copy = [self fileStubResponse];
    copy.path = [NSString stringWithString:response.path];
    copy.statusCode = response.statusCode;
    copy.filepath = response.filepath;
    copy.shouldTimeout = response.shouldTimeout;
    copy.uriCheckBlock = response.uriCheckBlock;
    copy.httpHeaders = response.httpHeaders;
    
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    return [NLTHTTPFileStubResponse fileStubResponseWithFileStubResponse:self];
}

- (void)setFilepath:(NSString *)filepath {
    if(filepath == nil){
        [_filepath release];
        return;
    }
    [_filepath release];
    _filepath = [filepath retain];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_filepath error:nil];
    if (fileAttributes == nil)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"file open aborted (file path=%@)", _filepath];
    }
    _fileLength = (UInt64)[[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];

}

- (NSString*)filepath {
    return _filepath;
}

- (void)dealloc
{
	if (_fileFD != NULL_FD)
	{
		
		close(_fileFD);
	}
	
	if (_buffer)
		free(_buffer);
	
	[super dealloc];
}

- (void)abort
{
	_aborted = YES;
    [NSException raise:NSInternalInconsistencyException
                format:@"file open aborted (file path=%@)", _filepath];
}

- (BOOL)openFile
{
	_fileFD = open([_filepath UTF8String], O_RDONLY);
	if (_fileFD == NULL_FD)
	{
		[self abort];
		return NO;
	}
	
	return YES;
}

- (BOOL)openFileIfNeeded
{
	if (_aborted)
	{
		return NO;
	}
	
	if (_fileFD != NULL_FD)
	{
		return YES;
	}
	
	return [self openFile];
}

- (UInt64)contentLength
{
	return _fileLength;
}

- (UInt64)offset
{
	return _fileOffset;
}

- (void)setOffset:(UInt64)offset
{
	if (![self openFileIfNeeded])
	{
		return;
	}
	
	_fileOffset = offset;
	
	off_t result = lseek(_fileFD, (off_t)offset, SEEK_SET);
	if (result == -1)
	{
		[self abort];
	}
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    if (![self openFileIfNeeded])
	{
		return nil;
	}
	
	UInt64 bytesLeftInFile = _fileLength - _fileOffset;
	
	NSUInteger bytesToRead = (NSUInteger)MIN(length, bytesLeftInFile);
	
	if (_buffer == NULL || _bufferSize < bytesToRead)
	{
		_bufferSize = bytesToRead;
		_buffer = reallocf(_buffer, (size_t)_bufferSize);
		
		if (_buffer == NULL)
		{
			[self abort];
			return nil;
		}
	}
	
	ssize_t result = read(_fileFD, _buffer, bytesToRead);
	
	if (result < 0)
	{
		[self abort];
		return nil;
	}
	else if (result == 0)
	{
		[self abort];
		return nil;
	}
	else // (result > 0)
	{
		_fileOffset += result;
		return [NSData dataWithBytes:_buffer length:result];
	}
}

- (BOOL)isDone
{
	return (_fileOffset == _fileLength);
}

- (NSInteger)status {
    return self.statusCode;
}

- (BOOL)delayResponeHeaders {
    return self.shouldTimeout;
}

@end
