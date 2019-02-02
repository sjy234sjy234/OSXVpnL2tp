//
//  main.m
//  VPNManager
//
//  Created by  沈江洋 on 13/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCPreferences.h>

#import "VPNAuthorizations.h"
#import "VPNServiceCreater.h"
#import "VPNServiceConfig.h"

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        for(int i=0;i<argc;++i)
        {
            printf("%s\n",argv[i]);
        }
        
        if(argc!=5)
        {
            NSLog(@"Valid Argvs: vpnname username password serverip");
            return 31;
        }
        
        SCPreferencesRef prefs = SCPreferencesCreateWithAuthorization(NULL, CFSTR("macosvpn"), NULL, [VPNAuthorizations create]);
        
        // Making sure other process cannot make configuration modifications
        // by obtaining a system-wide lock over the system preferences.
        if (SCPreferencesLock(prefs, TRUE))
        {
            NSLog(@"Gain Super Rights Success.");
        }
        else
        {
            NSLog(@"Gain Super Rights Failed.");
            return 32; // VPNExitCode.LockingPreferencesFailed
        }
        
        VPNServiceConfig *config=[[VPNServiceConfig alloc] init];
        config.name=[NSString stringWithUTF8String:argv[1]];
        config.username=[NSString stringWithUTF8String:argv[2]];
        config.password=[NSString stringWithUTF8String:argv[3]];
        
        NSString *endpointStringNumber=[NSString stringWithUTF8String:argv[4]];
        long long endpointLongNumber= [endpointStringNumber longLongValue];
        config.endpoint=@"";
        long tempMode=endpointLongNumber%256;
        endpointLongNumber/=256;
        //consider ip a.b.c.d, endpointLongNumber = a * 256 ^ 3 + b * 256 ^ 2 + c * 256 + d;
        config.endpoint= [NSString stringWithFormat: @"%d", tempMode];
        NSString *splitter=@".";
        for(int i=0;i<3;++i)
        {
            tempMode=endpointLongNumber%256;
            endpointLongNumber/=256;
            NSString *preString=[NSString stringWithFormat: @"%d.", tempMode];
            config.endpoint=[preString stringByAppendingString:config.endpoint];
        }
        
        config.disconnectOnSwitch=YES;
        config.disconnectOnLogout=YES;
        
        //create VPN here
        int exitCode=[VPNServiceCreater createServiceWithConfig:config UsingPreferencesRef:prefs];
        if(exitCode!=0)
        {
            NSLog(@"Failed to create vpn service.");
        }
        
        return exitCode;
    }
    
}
