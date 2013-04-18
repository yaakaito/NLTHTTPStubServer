//
//  NLTHTTPStubResponse.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubResponse.h"

#define kNLTHTTPStubResponseHeaderKeyContentType         (@"Content-Type")
#define kNLTHTTPStubResponseHeaderValueContentTypeJSON   (@"application/json; charset=%@")
#define kNLTHTTPStubResponseHeaderValueContentTypePlain  (@"text/plain; charset=%@")
#define kNLTHTTPStubResponseHeaderValueContentTypeHTML   (@"text/html; charset=%@")
#define kNLTHTTPStubResponseHeaderValueContentTypeXML    (@"text/xml; charset=%@")
#define kNLTHTTPStubResponseHeaderValueContentTypeBinary (@"application/octet-stream")
#define kNLTHTTPStubResponseHeaderValueCharsetUTF8       (@"utf-8")

@implementation NLTHTTPStubResponse

@synthesize path;
@synthesize statusCode;
@synthesize data;
@synthesize filepath;
@synthesize shouldTimeout;
@synthesize postBodyCheckBlock;
@synthesize postKeyValueBodyCheckBlock;
@synthesize httpHeaders;
@synthesize httpMethod;
@synthesize processingTimeSeconds;

+ (NLTHTTPStubResponse *)stubResponse {
    return [[NLTHTTPStubResponse alloc] init];
}

- (id)init {
    self = [super init];
    if(self){
        self.statusCode = 200;
        self.shouldTimeout = NO;
        self.httpHeaders = @{};
        self.httpMethod = @"GET";
        self.processingTimeSeconds = 0.0f;
    }
    return self;
}

- (void)postBodyCheckWithBlock:(NLTPostBodyCheckBlock)block {
    self.postBodyCheckBlock = block;
}

- (void)postKeyValueBodyCheckWithBlock:(NLTPostKeyValueBodyCheckBlock)block {
    self.postKeyValueBodyCheckBlock = block;
}

- (id)forPath:(id)path_ {
    return [self forPath:path_ HTTPMethod:@"GET"];
}

- (id)forPath:(id)path_ HTTPMethod:(NSString *)method_ {
    if([path_ isKindOfClass:[NLTPath class]]) {
        self.path = path_;
    }
    else if([path_ isKindOfClass:[NSString class]]){
        self.path = [NLTPath pathWithPathString:path_];
    }
    else {
        [NSException raise:NSInvalidArgumentException format:@"`path` is NSString or NLTPath (path = %@)", [path_ class]];
    }
    self.httpMethod = method_;
    return self;
}

- (id)andResponse:(NSData *)data_ {
    self.data = data_;
    return self;
}

- (void)setResponseResource:(NSString *)filename ofType:(NSString*)type {
    NSString *path_ = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:type];
    NSData *data_ = [NSData dataWithContentsOfFile:path_];
    self.data = data_;
}

- (id)andResponseResource:(NSString *)filename ofType:(NSString *)type {
    [self setResponseResource:filename ofType:type];
    return self;
}

- (id)andStatusCode:(NSInteger)statusCode_ {
    self.statusCode = statusCode_;
    return self;
}

- (id)andCheckPostBody:(NLTPostBodyCheckBlock)checkBlock_ {
    self.postBodyCheckBlock = checkBlock_;
    return self;
}

- (id)andCheckKeyValuePostBody:(NLTPostKeyValueBodyCheckBlock)checkBlock_ {
    self.postKeyValueBodyCheckBlock = checkBlock_;
    return self;
}

- (id)andTimeout {
    self.shouldTimeout = YES;
    return self;
}

- (id)andProcessingTime:(NSTimeInterval)processingTimeSeconds_ {
    self.processingTimeSeconds = processingTimeSeconds_;
    return self;
}

- (void)addContentType:(NSString*)contentType {
    NSMutableDictionary *base;
    if(self.httpHeaders){
        base = [NSMutableDictionary dictionaryWithDictionary:self.httpHeaders];
    }
    else {
        base = [NSMutableDictionary dictionary];
    }
    base[kNLTHTTPStubResponseHeaderKeyContentType] = contentType;
    self.httpHeaders = base;
}

- (NSString*)contentTypeJSON:(NSString*)charset {
    return [NSString stringWithFormat:kNLTHTTPStubResponseHeaderValueContentTypeJSON, charset];
}

- (id)andJSONHeader {
    [self addContentType:[self contentTypeJSON:kNLTHTTPStubResponseHeaderValueCharsetUTF8]];
    return self;
}

- (NSString*)contentTypePlain:(NSString*)charset {
    return [NSString stringWithFormat:kNLTHTTPStubResponseHeaderValueContentTypePlain, charset];
}

- (id)andPlainHeader {
    [self addContentType:[self contentTypePlain:kNLTHTTPStubResponseHeaderValueCharsetUTF8]];
    return self;
}

- (NSString*)contentTypeHTML:(NSString*)charset {
    return [NSString stringWithFormat:kNLTHTTPStubResponseHeaderValueContentTypeHTML, charset];
}

- (id)andHTMLHeader {
    [self addContentType:[self contentTypeHTML:kNLTHTTPStubResponseHeaderValueCharsetUTF8]];
    return self;
}

- (NSString*)contentTypeXML:(NSString*)charset {
    return [NSString stringWithFormat:kNLTHTTPStubResponseHeaderValueContentTypeXML, charset];
}

- (id)andXMLHeader {
    [self addContentType:[self contentTypeXML:kNLTHTTPStubResponseHeaderValueCharsetUTF8]];
    return self;
}

- (id)andBinaryHeader {
    [self addContentType:kNLTHTTPStubResponseHeaderValueContentTypeBinary];
    return self;
}

- (id)andContentTypeHeader:(NSString *)contentType {
    [self addContentType:contentType];
    return self;
}

- (id)andJSONResponse:(NSData *)data_ {
    return [[self andResponse:data_] andJSONHeader];
}

- (id)andPlainResponse:(NSData *)data_ {
    return [[self andResponse:data_] andPlainHeader];
}

- (id)andHTMLResponse:(NSData *)data_ {
    return [[self andResponse:data_] andHTMLHeader];
}

- (id)andXMLResponse:(NSData *)data_ {
    return [[self andResponse:data_] andXMLHeader];
}

- (id)andBinaryResponse:(NSData *)data_ {
    return [[self andResponse:data_] andBinaryHeader];
}

- (id)andContentType:(NSString *)contentType response:(NSData *)data_ {
    return [[self andResponse:data_] andContentTypeHeader:contentType];
}

- (id)andJSONResponseResource:(NSString *)filename ofType:(NSString *)type {
    return [[self andResponseResource:filename ofType:type] andJSONHeader];
}

- (id)andPlainResponseResource:(NSString *)filename ofType:(NSString *)type {
    return [[self andResponseResource:filename ofType:type] andPlainHeader];
}

- (id)andHTMLResponseResource:(NSString *)filename ofType:(NSString *)type {
    return [[self andResponseResource:filename ofType:type] andHTMLHeader];
}

- (id)andXMLResponseResource:(NSString *)filename ofType:(NSString *)type {
    return [[self andResponseResource:filename ofType:type] andXMLHeader];
}

- (id)andBinaryResponseResource:(NSString *)filename ofType:(NSString *)type {
    return [[self andResponseResource:filename ofType:type] andBinaryHeader];
}

- (id)andContentType:(NSString *)contentType resource:(NSString *)filename ofType:(NSString *)type {
    return [[self andResponseResource:filename ofType:type] andContentTypeHeader:contentType];
}

- (id)andJSONHeader:(NSString *)charset {
    [self addContentType:[self contentTypeJSON:charset]];
    return self;
}

- (id)andPlainHeader:(NSString *)charset {
    [self addContentType:[self contentTypePlain:charset]];
    return self;
}

- (id)andHTMLHeader:(NSString *)charset {
    [self addContentType:[self contentTypeHTML:charset]];
    return self;
}

- (id)andXMLHeader:(NSString *)charset {
    [self addContentType:[self contentTypeXML:charset]];
    return self;
}

- (id)andJSONResponse:(NSData *)data_ charset:(NSString *)charset {
    return [[self andResponse:data_] andJSONHeader:charset];
}

- (id)andPlainResponse:(NSData *)data_ charset:(NSString *)charset {
    return [[self andResponse:data_] andPlainHeader:charset];
}

- (id)andHTMLResponse:(NSData *)data_ charset:(NSString *)charset {
    return [[self andResponse:data_] andHTMLHeader:charset];
}

- (id)andXMLResponse:(NSData *)data_ charset:(NSString *)charset {
    return [[self andResponse:data_] andXMLHeader:charset];
}

- (id)andJSONResponseResource:(NSString *)filename ofType:(NSString *)type charset:(NSString *)charset {
    return [[self andResponseResource:filename ofType:type] andJSONHeader:charset];
}

- (id)andPlainResponseResource:(NSString *)filename ofType:(NSString *)type charset:(NSString *)charset {
    return [[self andResponseResource:filename ofType:type] andPlainHeader:charset];
}

- (id)andHTMLResponseResource:(NSString *)filename ofType:(NSString *)type charset:(NSString *)charset {
    return [[self andResponseResource:filename ofType:type] andHTMLHeader:charset];
}

- (id)andXMLResponseResource:(NSString *)filename ofType:(NSString *)type charset:(NSString *)charset {
    return [[self andResponseResource:filename ofType:type] andXMLHeader:charset];
}

@end
