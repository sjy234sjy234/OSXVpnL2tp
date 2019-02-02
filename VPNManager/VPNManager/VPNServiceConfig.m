/*
 Copyright (c) 2015 halo. https://github.com/halo/macosvpn

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "VPNServiceConfig.h"

#import <SystemConfiguration/SystemConfiguration.h>

@implementation VPNServiceConfig

@synthesize serviceID, name, endpoint, username, password, sharedSecret, localIdentifier;
@synthesize enableSplitTunnel, disconnectOnSwitch, disconnectOnLogout;



- (CFDictionaryRef) L2TPPPPConfig {
  CFStringRef keys[6] = { NULL, NULL, NULL, NULL, NULL, NULL };
  CFStringRef vals[6] = { NULL, NULL, NULL, NULL, NULL, NULL };
  CFIndex count = 0;

    
  keys[count] = kSCPropNetPPPCommRemoteAddress;
  vals[count++] = (__bridge CFStringRef)self.endpoint;

    
  keys[count] = kSCPropNetPPPAuthName;
  vals[count++] = (__bridge CFStringRef)self.username;

    
    
  keys[count] = kSCPropNetPPPAuthPassword;
  vals[count++] = (__bridge CFStringRef)self.serviceID;
    
    

  keys[count] = kSCPropNetPPPAuthPasswordEncryption;
  vals[count++] = kSCValNetPPPAuthPasswordEncryptionKeychain;

  int switchOne = self.disconnectOnSwitch ? 1 : 0;
  keys[count] = kSCPropNetPPPDisconnectOnFastUserSwitch;
  // X-Code warns on this (CFString VS. CFNumber), but it should not matter, CFNumber is the correct type I think, as you can verify in the resulting /Library/Preferences/SystemConfiguration/preferences.plist file.
  // See also https://developer.apple.com/library/prerelease/ios/documentation/CoreFoundation/Conceptual/CFPropertyLists/Articles/Numbers.html
  #pragma clang diagnostic ignored "-Wincompatible-pointer-types"
  vals[count++] = CFNumberCreate(NULL, kCFNumberIntType, &switchOne);
  #pragma clang diagnostic pop

  int logoutOne = self.disconnectOnLogout ? 1 : 0;
  keys[count] = kSCPropNetPPPDisconnectOnLogout;
  #pragma clang diagnostic ignored "-Wincompatible-pointer-types"
  vals[count++] = CFNumberCreate(NULL, kCFNumberIntType, &logoutOne);
  #pragma clang diagnostic pop
    
    

  return CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&vals, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

- (CFDictionaryRef) L2TPIPSecConfig {
  uint size;
  if (self.localIdentifier) size = 5; else size = 3;

  CFStringRef keys[size];
  CFStringRef vals[size];
  CFIndex count = 0;

  keys[count] = kSCPropNetIPSecAuthenticationMethod;
  vals[count++] = kSCValNetIPSecAuthenticationMethodSharedSecret;

  keys[count] = kSCPropNetIPSecSharedSecretEncryption;
  vals[count++] = kSCValNetIPSecSharedSecretEncryptionKeychain;

  keys[count] = kSCPropNetIPSecSharedSecret;
  vals[count++] = (__bridge CFStringRef)[NSString stringWithFormat:@"%@.SS", self.serviceID];

  if (self.localIdentifier) {
    NSLog(@"Assigning group name <%@> to L2TP service config", self.localIdentifier);

    keys[count]   = kSCPropNetIPSecLocalIdentifier;
    vals[count++] = (__bridge CFStringRef)self.localIdentifier;

    keys[count]    = kSCPropNetIPSecLocalIdentifierType;
    vals[count++]  = kSCValNetIPSecLocalIdentifierTypeKeyID;
  }


  return CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&vals, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

- (CFDictionaryRef) L2TPIPv4Config {
    CFStringRef keys[5] = { NULL, NULL, NULL, NULL, NULL };
    CFStringRef vals[5] = { NULL, NULL, NULL, NULL, NULL };
    CFIndex count = 0;
    
    keys[count] = kSCPropNetIPv4ConfigMethod;
    vals[count++] = kSCValNetIPv4ConfigMethodPPP;
    
    if (!self.enableSplitTunnel) {
        int one = 1;
        keys[count] = kSCPropNetOverridePrimary;
        
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
        vals[count++] = CFNumberCreate(NULL, kCFNumberIntType, &one);
#pragma clang diagnostic pop
    }
    
    return CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&vals, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}


@end
