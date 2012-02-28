//
//  NLTHGlobalSettings.h
//  NLTHTTPStubServer
//
//  Created by KAZUMA Ukyo.
//  Copyright (c) 2012 yaakaito.org All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NLTHGlobalSettings : NSObject 
@property NSInteger port;
@property BOOL autoStart;

+ (NLTHGlobalSettings*)globalSettings;

@end
