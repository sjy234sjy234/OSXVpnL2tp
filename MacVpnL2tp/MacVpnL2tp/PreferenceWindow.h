//
//  PreferenceWindow.h
//  MacVpnL2tp
//
//  Created by  沈江洋 on 21/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// declare our class
@class PreferenceWindow;

// define the protocol for the delegate
@protocol PreferenceWindowDelegate

// define protocol functions that can be used in any class using this delegate
-(void)updateConnectionStatus: (BOOL)isConnected;


@end

@interface PreferenceWindow : NSWindowController

@property (weak) IBOutlet NSTextField *labelUser;

@property (weak) IBOutlet NSTextField *labelPassword;

@property (weak) IBOutlet NSTextField *tfUser;

@property (weak) IBOutlet NSSecureTextField *stfPassword;

@property (weak) IBOutlet NSButton *btnConnect;

@property (weak) IBOutlet NSButton *btnDisConnect;

@property (weak) IBOutlet NSTextField *labelLog;

@property (unsafe_unretained) IBOutlet NSTextView *tvLog;

// define delegate property
@property (nonatomic, assign) id  delegate;

-(void) executePressConnect;

-(void) executePressDisConnect;

@end
