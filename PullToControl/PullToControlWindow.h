//
//  PullToControlWindow.h
//  PullToControl
//
//  Created by HatanoKenta on 2017/02/22.
//  Copyright © 2017年 Nita. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PullToControlWindow : NSWindow <NSWindowDelegate, NSDraggingDestination>

@property (strong) NSString *filePath;

@property (weak) IBOutlet NSTextField *lLabel;
@property (weak) IBOutlet NSWindow *wSubWindow;

@property (weak) IBOutlet NSMenuItem *miFileName;
@property (weak) IBOutlet NSMenuItem *miSeparator;

@property (weak) IBOutlet NSTextField *lAppCurrent;
@property (weak) IBOutlet NSTextField *lAppBefore1;
@property (weak) IBOutlet NSTextField *lAppBefore2;
@property (weak) IBOutlet NSTextField *lAppBefore3;
@property (weak) IBOutlet NSTextField *lAppBefore4;
@property (weak) IBOutlet NSTextField *lAppAfter1;
@property (weak) IBOutlet NSTextField *lAppAfter2;
@property (weak) IBOutlet NSTextField *lAppAfter3;
@property (weak) IBOutlet NSTextField *lAppAfter4;

- (IBAction)fileNameSelected:(id)sender;

+ (void)showMissionControl;
+ (void)showDashboard;
+ (void)showLaunchpad;
+ (void)sleep;

@end
