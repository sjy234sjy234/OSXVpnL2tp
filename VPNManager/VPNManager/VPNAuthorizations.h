//
//  VPNAuthorizations.h
//  VPNManager
//
//  Created by  沈江洋 on 13/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import <Security/Authorization.h>
#import <Foundation/Foundation.h>

@interface VPNAuthorizations: NSObject

+ (AuthorizationRef) create;

@end
