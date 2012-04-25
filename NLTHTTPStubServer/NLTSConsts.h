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

@protocol NLTResponseChaining
- (id)forPath:(NSString*)path;
- (id)andResponse:(NSData*)data;
- (id)andStatusCode:(NSUInteger)statusCode;
- (id)andCheckURI:(__httpStubResponseURICheck)checkBlock;
@end


#endif
