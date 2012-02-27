//
//  NLTHGlobalSettings.h
//  NLTHTTPStubServer
//
//  Created by  on 12/02/28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLTHGlobalSettings : NSObject 
@property NSInteger port;
@property BOOL autoStart;

+ (NLTHGlobalSettings*)globalSettings;

@end
