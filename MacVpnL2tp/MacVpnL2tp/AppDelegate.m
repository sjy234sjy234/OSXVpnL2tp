//
//  AppDelegate.m
//  MacVpnL2tp
//
//  Created by  沈江洋 on 20/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

@protocol PreferenceWindow
@end

#import "AppDelegate.h"
#import "PreferenceWindow.h"



@interface AppDelegate () <PreferenceWindow>
{
    PreferenceWindow *preferenceWindow;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"L2TP"];
    [self.statusItem setHighlightMode:YES];
    
    preferenceWindow=[[PreferenceWindow alloc] initWithWindowNibName:@"PreferenceWindow"];
    [preferenceWindow.window setLevel:NSStatusWindowLevel];
    preferenceWindow.delegate=self;
    [preferenceWindow showWindow:self];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (IBAction)onPreferenceItem:(NSMenuItem *)sender
{
    [preferenceWindow showWindow:self];
}


- (IBAction)onConnectItem:(NSMenuItem *)sender
{
    [preferenceWindow showWindow:self];
    [preferenceWindow executePressConnect];
}

- (IBAction)onDisconnectItem:(NSMenuItem *)sender
{
    [preferenceWindow executePressDisConnect];
}

- (IBAction)onExitItem:(NSMenuItem *)sender
{
    exit(0);
}

-(void)updateConnectionStatus:(BOOL) isConnected
{
    if(isConnected)
    {
        [_connectionItem setTitle: @"连接状态: On"];
        [_connectItem setEnabled: NO];
        [_disconnectItem setEnabled: YES];
        [preferenceWindow close];
    }
    else
    {
        [_connectionItem setTitle: @"连接状态: Off"];
        [_connectItem setEnabled: YES];
        [_disconnectItem setEnabled: NO];
    }
}

@end
