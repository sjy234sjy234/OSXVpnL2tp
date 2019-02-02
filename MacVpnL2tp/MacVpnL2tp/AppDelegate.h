//
//  AppDelegate.h
//  MacVpnL2tp
//
//  Created by  沈江洋 on 20/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;

@property (strong, nonatomic) NSStatusItem *statusItem;

@property (weak) IBOutlet NSMenuItem *connectionItem;

@property (weak) IBOutlet NSMenuItem *connectItem;

@property (weak) IBOutlet NSMenuItem *disconnectItem;

@property (weak) IBOutlet NSMenuItem *exitItem;

@end

