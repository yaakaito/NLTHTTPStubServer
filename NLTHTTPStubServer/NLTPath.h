//
//  NLTPath.h
//  NLTHTTPStubServer
//
//  Created by yaakaito on 12/09/02.
//
//

#import <Foundation/Foundation.h>

@interface NLTWildcard : NSObject
@end

@interface NLTPath : NSObject<NSCopying>

@property (nonatomic, strong, readonly) NSString *pathString;
@property (nonatomic, strong, readonly) NSDictionary *parameters;

+ (NLTPath*)pathWithPathString:(NSString*)pathString;
+ (NLTPath*)pathWithPathString:(NSString*)pathString andParameters:(NSDictionary*)parameters;

// for v2s feature "global stub".
+ (NLTPath*)pathWithPath:(NLTPath*)path andParameters:(NSDictionary*)parameters;

- (BOOL)isMatchURL:(NSURL*)url;
//- (BOOL)isMatchRelativePathString:(NSString*)pathString;

+ (id)anyValue;
@end
