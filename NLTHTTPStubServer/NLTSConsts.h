//
//  NLTSConsts.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo on 12/04/25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef NLTHTTPStubServer_NLTSConsts_h
#define NLTHTTPStubServer_NLTSConsts_h

#import <Foundation/Foundation.h>

@protocol NLTServerChaining
- (id)expect;
- (id)stub;
@end

typedef void(^NLTPostBodyCheckBlock)(NSData* postBody);
typedef void(^NLTPostKeyValueBodyCheckBlock)(NSDictionary *postBody);

@protocol NLTResponseChaining
// NSString or NLTPath
- (id)forPath:(id)path;
- (id)forPath:(id)path HTTPMethod:(NSString *)method;
- (id)andResponse:(NSData*)data;
- (id)andResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andStatusCode:(NSInteger)statusCode;
- (id)andCheckPostBody:(NLTPostBodyCheckBlock)checkBlock;
- (id)andCheckKeyValuePostBody:(NLTPostKeyValueBodyCheckBlock)checkBlock;
- (id)andTimeout;
- (id)andProcessingTime:(NSTimeInterval)processingTimeSeconds;
@end

@protocol NLTResponseHeaderPresetChaining
- (id)andJSONHeader;
- (id)andPlainHeader;
- (id)andHTMLHeader;
- (id)andXMLHeader;
- (id)andBinaryHeader;
- (id)andContentTypeHeader:(NSString*)contentType;
@end

@protocol NLTResponseDataPresetChaining
- (id)andJSONResponse:(NSData*)data;
- (id)andPlainResponse:(NSData*)data;
- (id)andHTMLResponse:(NSData*)data;
- (id)andXMLResponse:(NSData*)data;
- (id)andBinaryResponse:(NSData*)data;
- (id)andContentType:(NSString*)contentType response:(NSData*)data;
- (id)andJSONResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andPlainResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andHTMLResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andXMLResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andBinaryResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andContentType:(NSString*)contentType resource:(NSString*)filename ofType:(NSString*)type;
@end

@protocol NLTResponseHeaderCharsetChaining
- (id)andJSONHeader:(NSString*)charset;
- (id)andPlainHeader:(NSString*)charset;
- (id)andHTMLHeader:(NSString*)charset;
- (id)andXMLHeader:(NSString*)charset;
@end

@protocol NLTResponseDataCharsetChaining
- (id)andJSONResponse:(NSData*)data charset:(NSString*)charset;
- (id)andPlainResponse:(NSData*)data charset:(NSString*)charset;
- (id)andHTMLResponse:(NSData*)data charset:(NSString*)charset;
- (id)andXMLResponse:(NSData*)data charset:(NSString*)charset;
- (id)andJSONResponseResource:(NSString*)filename ofType:(NSString*)type charset:(NSString*)charset;
- (id)andPlainResponseResource:(NSString*)filename ofType:(NSString*)type charset:(NSString*)charset;
- (id)andHTMLResponseResource:(NSString*)filename ofType:(NSString*)type charset:(NSString*)charset;
- (id)andXMLResponseResource:(NSString*)filename ofType:(NSString*)type charset:(NSString*)charset;
@end
#endif
