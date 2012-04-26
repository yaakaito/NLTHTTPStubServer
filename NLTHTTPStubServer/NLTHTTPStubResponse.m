//
//  NLTHTTPStubResponse.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import "NLTHTTPStubResponse.h"

#define kNLTHTTPStubResponseHeaderKeyContentType        (@"Content-Type")
#define kNLTHTTPStubResponseHeaderValueContentTypeJSON  (@"application/json; charset=%@")
#define kNLTHTTPStubResponseHeaderValueContentTypePlain (@"text/plain; charset=%@")
#define kNLTHTTPStubResponseHeaderValueContentTypeHTML  (@"text/html; charset=%@")
#define kNLTHTTPStubResponseHeaderValueContentTypeXML   (@"text/xml; charset=%@")
#define kNLTHTTPStubResponseHeaderValueCharsetUTF8      (@"utf-8")

@implementation NLTHTTPStubResponse

@synthesize path;
@synthesize statusCode;
@synthesize data;
@synthesize filepath;
@synthesize shouldTimeout;
@synthesize uriCheckBlock;
@synthesize httpHeaders;

+ (NLTHTTPStubResponse *)stubResponse {
    return [[[NLTHTTPStubResponse alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if(self){
        self.statusCode = 200;
        self.shouldTimeout = NO;
        self.httpHeaders = [NSDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    
    self.path = nil;
    self.data = nil;
    self.filepath = nil;
    self.httpHeaders = nil;
    
    [super dealloc];
}

- (void)URICheckWithBlock:(__httpStubResponseURICheck)block {
    self.uriCheckBlock = block;
}


- (id)forPath:(NSString *)path_ {
    self.path = path_;
    return self;
}

- (id)andResponse:(NSData *)data_ {
    self.data = data_;
    return self;
}

- (id)andStatusCode:(NSInteger)statusCode_ {
    self.statusCode = statusCode_;
    return self;
}

- (id)andCheckURI:(__httpStubResponseURICheck)checkBlock_ {
    self.uriCheckBlock = checkBlock_;
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
    [base setObject:contentType forKey:kNLTHTTPStubResponseHeaderKeyContentType];
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
@end
