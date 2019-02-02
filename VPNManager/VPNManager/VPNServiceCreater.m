//
//  VPNServiceCreater.m
//  VPNManager
//
//  Created by  沈江洋 on 14/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkConfiguration.h>
#import <CoreFoundation/CFDictionary.h>

#import "VPNServiceCreater.h"
#import "VPNKeychain.h"

@implementation VPNServiceCreater

+ (int) createServiceWithConfig: (VPNServiceConfig*) config UsingPreferencesRef: (SCPreferencesRef) prefs
{
    NSLog(@"Interface Initialization...");
    SCNetworkInterfaceRef initialTopInterface;
    SCNetworkInterfaceRef initialBottomInterface;
    // L2TP on top of IPv4
    initialBottomInterface=SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeL2TP);
    // PPP on top of L2TP
    initialTopInterface = SCNetworkInterfaceCreateWithInterface(initialBottomInterface, kSCNetworkInterfaceTypePPP);
    
    if(initialTopInterface == nil){
        NSLog(@"Interface Initialization Failed");
        return -1;
    }
    
    NSLog(@"Instantiating Interface References...");
    NSLog(@"Creating a new, fresh VPN service in memory using the interface we already created");
    SCNetworkServiceRef service = SCNetworkServiceCreate(prefs, initialTopInterface);
    if(service == nil) {
        NSLog(@"Instantiating Interface Failed");
        return -1;
    }
    
    NSLog(@"Set VPN Service Name...");
    Boolean success = SCNetworkServiceSetName(service, (__bridge CFStringRef)config.name);
    if (!success)
    {
        NSLog(@"Set VPN Service Name Failed");
        return -1;
    }
    
    NSLog(@"Get Service ID...");
    CFStringRef serviceIDCF = SCNetworkServiceGetServiceID(service);
    NSString *serviceID=(__bridge NSString *)serviceIDCF;
    if(serviceID==nil||[serviceID length]==0)
    {
        NSLog(@"Get Service ID Failed");
        return -1;
    }
    config.serviceID=serviceID;
    
    NSLog(@"Reloading Top Interface...");
    // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
    SCNetworkInterfaceRef topInterface = SCNetworkServiceGetInterface(service);
    if(topInterface==nil)
    {
        NSLog(@"Reloading Top Interface Failed");
        return -1;
    }
    
    NSLog(@"Configuring VPN Service...");
    // Let's apply all configuration to the PPP interface
    // Specifically, the servername, account username and password
    success=SCNetworkInterfaceSetConfiguration(topInterface, config.L2TPPPPConfig);
    if (!success)
    {
        NSLog(@"Configure PPP Interface Failed");
        return -1;
    }
    // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
    
    //may be a problem here
    CFStringRef thingy=(__bridge CFStringRef)@"IPSec";
    success=SCNetworkInterfaceSetExtendedConfiguration(topInterface, thingy, config.L2TPIPSecConfig);
    if (!success)
    {
        NSLog(@"Configure IPSec on PPP interface Failed");
        return -1;
    }
    
    NSLog(@"Add Default Protocols...");
    success=SCNetworkServiceEstablishDefaultConfiguration(service);
    if (!success) {
        NSLog(@"Add Default Protocols Failed");
        return -1;
    }
    
    NSLog(@"Fetching All Network Services...");
    SCNetworkSetRef networkSet = SCNetworkSetCopyCurrent(prefs);
    if(networkSet==nil) {
        NSLog(@"Fetching All Network Services Failed");
        return -1;
    }
    
    NSLog(@"Retrieve Network Services Set...");
    CFArrayRef existServices = SCNetworkSetCopyServices(networkSet);
    if (existServices==nil)
    {
        NSLog(@"Retrieve Network Services Set Failed");
        return -1;
    }
    
    CFIndex existServiceCount = CFArrayGetCount(existServices);
    for (CFIndex i = 0; i < existServiceCount; i++) {
        SCNetworkServiceRef existService=CFArrayGetValueAtIndex(existServices, i);
        
        CFStringRef serviceNameCF = SCNetworkServiceGetName(existService);
        if(serviceNameCF==nil)
        {
            NSLog(@"SCNetworkServiceGetName Failed");
            return -1;
        }
        NSString* serviceName = (__bridge NSString*)serviceNameCF;
        
        CFStringRef serviceIDCF = SCNetworkServiceGetServiceID(existService);
        if(serviceIDCF==nil){
            NSLog(@"SCNetworkServiceGetServiceID Failed");
            return -1;

        }
        NSString* serviceID = (__bridge NSString*)serviceIDCF;
        
        if([serviceName isEqualToString:config.name])
        {
            NSLog(@"Service %@ Redefined.", serviceName);
            NSLog(@"Removing duplicate VPN Service...");
            success=SCNetworkServiceRemove(existService);
            if(!success)
            {
                NSLog(@"Removing duplicate VPN Service Failed.");
                return -1;
            }
            break;
        }
    }
    
    NSLog(@"Fetching IPv4 Protocol Of Service...");
    SCNetworkProtocolRef serviceProtocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4);
    if (serviceProtocol == nil)
    {
        NSLog(@"Fetching IPv4 Protocol Of Service Failed");
        return -1;
    }
    NSLog(@"Configuring IPv4 protocol Of Service...");
    success=SCNetworkProtocolSetConfiguration(serviceProtocol, config.L2TPIPv4Config);
    if (!success) {
        NSLog(@"Configuring IPv4 protocol Of Service Failed");
        return -1;
    }
    
    NSLog(@"Add Service NetworkSet...");
    success=SCNetworkSetAddService(networkSet, service);
    if (!success)
    {
        NSLog(@"Add Service NetworkSet Failed");
        return -1;
    }
    
    NSLog(@"Preparing Keychain...");
    if (config.password != nil)
    {
        
        int code = [VPNKeychain createPasswordKeyChainItem: config.name forService: config.serviceID withAccount: config.username andPassword: config.password];
        if (code > 0)
        {
            NSLog(@"CreatePasswordKeyChainItem Failed");
            return -1;
        }
    }
    if (config.sharedSecret != nil)
    {
        int code = [VPNKeychain createSharedSecretKeyChainItem: config.name forService: config.serviceID withPassword: config.sharedSecret];
        if (code > 0)
        {
            NSLog(@"CreateSharedSecretKeyChainItem Failed");
            return -1;
        }
    }
    
    NSLog(@"Commiting All Changes...");
    success=SCPreferencesCommitChanges(prefs);
    if (!success)
    {
        NSLog(@"Commit Preferences With Service Failed");
        return -1;
    }
    success=SCPreferencesApplyChanges(prefs);
    if (!success)
    {
        NSLog(@"Apply Changes With Service Failed");
        return -1;
    }
    
    NSLog(@"Successfully created %@", config.name);
    
    return 0;
}

@end
