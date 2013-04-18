//
//  NLTPath.m
//  NLTHTTPStubServer
//
//  Created by yaakaito on 12/09/02.
//
//

#import "NLTPath.h"

@implementation NLTWildcard
@end

@implementation NSURL(NLTPath)
- (NSDictionary*)queryParameters {
    
    NSArray *queryConmponents = [[self query] componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *component in queryConmponents) {
        NSArray *keyValueComponents = [component componentsSeparatedByString:@"="];
        parameters[keyValueComponents[0]] = keyValueComponents[1];
    }
    
    return parameters;
}
@end

@implementation NLTPath

@synthesize pathString = _pathString;
@synthesize parameters = _parameters;

+ (NLTPath *)pathWithPathString:(NSString *)pathString {
    
    return [[self alloc] initWithPathString:pathString andParameters:nil];
}

+ (NLTPath *)pathWithPathString:(NSString *)pathString andParameters:(NSDictionary *)parameters {

    return [[self alloc] initWithPathString:pathString andParameters:parameters];
}

+ (NLTPath *)pathWithPath:(NLTPath *)path andParameters:(NSDictionary *)parameters {
    
    NSMutableDictionary *newParameters = [parameters mutableCopy];
    [newParameters setValuesForKeysWithDictionary:path.parameters];
    return [[self alloc] initWithPathString:path.pathString andParameters:newParameters];
}

+ (id)anyValue {
    return [[NLTWildcard alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] initWithPathString:self.pathString andParameters:self.parameters];
    
    return copiedObject;
}

- (id)initWithPathString:(NSString*)pathString andParameters:(NSDictionary*)parameters {
    
    self = [super init];
    if(self) {
        _pathString = pathString;
        _parameters = parameters;
    }
    return self;
}


- (BOOL)isMatchURL:(NSURL *)url {
    
    NSString *otherPath = [url relativePath];
    if(![otherPath isEqualToString:[[NSURL URLWithString:self.pathString] relativePath]]) {
        return NO;
    }
    
    NSDictionary *otherParameters = [url queryParameters];
    
    NSMutableArray *parameterAllKeys = [[self.parameters allKeys] mutableCopy];
    NSArray *otherParameterAllKeys = [otherParameters allKeys];
    
    if([parameterAllKeys count] != [otherParameterAllKeys count]) {
        return NO;
    }
    
    for (NSString* key in otherParameterAllKeys) {
        if([parameterAllKeys indexOfObject:key] == NSNotFound) {
            return NO;
        }
        
        if(![(self.parameters)[key] isKindOfClass:[NLTWildcard class]] &&
           ![(self.parameters)[key] isEqualToString:otherParameters[key]]) {
            return NO;
        }
        
        [parameterAllKeys removeObject:key];
    }
    
    return [parameterAllKeys count] == 0 ? YES : NO;
}

@end
