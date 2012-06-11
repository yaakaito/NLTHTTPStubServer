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
- (id)stub;
@end

typedef void(^__httpStubResponseURICheck)(NSURL *URI);
typedef void(^__httpStubResponsePostBodyCheck)(NSDictionary *postBody);

@protocol NLTResponseChaining
- (id)forPath:(NSString*)path;
- (id)andResponse:(NSData*)data;
- (id)andResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andStatusCode:(NSInteger)statusCode;
- (id)andCheckURI:(__httpStubResponseURICheck)checkBlock;
- (id)andCheckPostBody:(__httpStubResponsePostBodyCheck)checkBlock;
- (id)andTimeout;
@end

@protocol NLTResponseHeaderPresetChaining
- (id)andJSONHeader;
- (id)andPlainHeader;
- (id)andHTMLHeader;
- (id)andXMLHeader;
@end

@protocol NLTResponseDataPresetChaining
- (id)andJSONResponse:(NSData*)data;
- (id)andPlainResponse:(NSData*)data;
- (id)andHTMLResponse:(NSData*)data;
- (id)andXMLResponse:(NSData*)data;
- (id)andJSONResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andPlainResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andHTMLResponseResource:(NSString*)filename ofType:(NSString*)type;
- (id)andXMLResponseResource:(NSString*)filename ofType:(NSString*)type;
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
