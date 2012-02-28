//
//  NLTHGlobalSettings.m
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLTHGlobalSettings.h"

@implementation NLTHGlobalSettings
@synthesize port;
@synthesize autoStart;

+ (NLTHGlobalSettings*)globalSettings {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        ((NLTHGlobalSettings*)_sharedObject).port = 12345;
        ((NLTHGlobalSettings*)_sharedObject).autoStart = NO;
    });
    return _sharedObject;
}
@end
