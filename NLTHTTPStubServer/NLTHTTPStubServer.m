//
//  NLTHTTPStubServer.m
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo on 12/02/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NLTHTTPStubServer.h"

@implementation NLTHTTPStubServer

@synthesize stubResponses = _stubResponses;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NLTHTTPStubServer *)currentStubServer {
    return [[self class] __currentStubServer:[[self class] __stubGetter]];
}

+ (void)setCurrentStubServer:(NLTHTTPStubServer *)stubServer {
    [[self class] __currentStubServer:stubServer];
}

+ (NLTHTTPStubServer *)__currentStubServer:(NLTHTTPStubServer *)stubServer {
    __strong static id _sharedObject = nil;
    if(![stubServer isKindOfClass:[NLTHCurrentStubGetter class]]){
        [_sharedObject release];
        _sharedObject = [stubServer retain]; 
    }
    return _sharedObject;
}

+ (NLTHCurrentStubGetter*)__stubGetter {
    return [[[NLTHCurrentStubGetter alloc] init] autorelease];
}

+ (NLTHTTPStubServer *)stubServer {
    return [[[[self class] alloc] init] autorelease];
}

+ (NLTHGlobalSettings*)globalSettings {
    return [NLTHGlobalSettings globalSettings];
}

@end


@implementation NLTHCurrentStubGetter
@end