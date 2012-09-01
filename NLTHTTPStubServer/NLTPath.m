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
        [parameters setObject:[keyValueComponents objectAtIndex:1] forKey:[keyValueComponents objectAtIndex:0]];
    }
    
    return parameters;
}
@end

@implementation NLTPath
{
    NSString *_pathString;
    NSDictionary *_parameters;
}

@synthesize pathString = _pathString;
@synthesize parameters = _parameters;

+ (NLTPath *)pathWithPathString:(NSString *)pathString {
    
    return [[[self alloc] initWithPathString:pathString andParameters:nil] autorelease];
}

+ (NLTPath *)pathWithPathString:(NSString *)pathString andParameters:(NSDictionary *)parameters {

    return [[[self alloc] initWithPathString:pathString andParameters:parameters] autorelease];
}

+ (NLTPath *)pathWithPath:(NLTPath *)path andPatameters:(NSDictionary *)parameters {
    
    NSMutableDictionary *newParameters = [[parameters mutableCopy] autorelease];
    [newParameters setValuesForKeysWithDictionary:path.parameters];
    return [[self alloc] initWithPathString:path.pathString andParameters:newParameters];
}

+ (id)anyValue {
    return [[[NLTWildcard alloc] init] autorelease];
}

- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] initWithPathString:self.pathString andParameters:self.parameters];
    
    return copiedObject;
}

- (id)initWithPathString:(NSString*)pathString andParameters:(NSDictionary*)parameters {
    
    self = [super init];
    if(self) {
        _pathString = [pathString retain];
        _parameters = [parameters retain];
    }
    return self;
}

- (void)dealloc {
    
    [_pathString release];
    [_parameters release];
    
    [super dealloc];
}

- (BOOL)isMatchURL:(NSURL *)url {
    
    NSString *otherPath = [url relativePath];
    if(![otherPath isEqualToString:[[NSURL URLWithString:self.pathString] relativePath]]) {
        return NO;
    }
    
    NSDictionary *otherParameters = [url queryParameters];
    
    NSMutableArray *parameterAllKeys = [[[self.parameters allKeys] mutableCopy] autorelease];
    NSArray *otherParameterAllKeys = [otherParameters allKeys];
    
    if([parameterAllKeys count] != [otherParameterAllKeys count]) {
        return NO;
    }
    
    for (NSString* key in otherParameterAllKeys) {
        if([parameterAllKeys indexOfObject:key] == NSNotFound) {
            return NO;
        }
        
        if(![[self.parameters objectForKey:key] isKindOfClass:[NLTWildcard class]] &&
           ![[self.parameters objectForKey:key] isEqualToString:[otherParameters objectForKey:key]]) {
            return NO;
        }
        
        [parameterAllKeys removeObject:key];
    }
    
    return [parameterAllKeys count] == 0 ? YES : NO;
}

@end
