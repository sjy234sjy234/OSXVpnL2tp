//
//  VPNServiceCreater.h
//  VPNManager
//
//  Created by  沈江洋 on 14/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPNServiceConfig.h"

@interface VPNServiceCreater : NSObject

+ (int) createServiceWithConfig: (VPNServiceConfig*) config UsingPreferencesRef: (SCPreferencesRef) prefs;

@end
