//
//  VPNAuthorizations.m
//  VPNManager
//
//  Created by  沈江洋 on 13/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import "VPNAuthorizations.h"
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCPreferences.h>
#import <Security/Authorization.h>

@implementation VPNAuthorizations

+ (AuthorizationRef) create
{
    AuthorizationRef auth=nil;
    
    AuthorizationFlags flags=kAuthorizationFlagExtendRights|kAuthorizationFlagInteractionAllowed|kAuthorizationFlagPreAuthorize;
    
    OSStatus status=AuthorizationCreate(nil, nil, flags, &auth);
    
    return auth;
}

@end
