//
//  NLTHTTPStubResponse.h
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPResponse.h"

@interface NLTHTTPStubResponse : NSObject <HTTPResponse> {
    NSString *_path;
    NSInteger _statusCode;
    NSData   *_data;
    
    NSInteger _offset;
}
@property(nonatomic,retain) NSString *path;
@property NSInteger                   statusCode;
@property(nonatomic,retain) NSData   *data;

+ (NLTHTTPStubResponse*)stubResponseWithPath:(NSString *)path
                                  statusCode:(NSInteger)statusCode
                                        data:(NSData *)data;
@end
