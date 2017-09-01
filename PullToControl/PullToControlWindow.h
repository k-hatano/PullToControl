//
//  PullToControlWindow.h
//  PullToControl
//
//  Created by HatanoKenta on 2017/02/22.
//  Copyright © 2017年 Nita. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PullToControlWindow : NSWindow <NSWindowDelegate, NSDraggingDestination, NSTableViewDelegate, NSTableViewDataSource>

@property (strong) NSString *filePath;

@property (weak) IBOutlet NSTextField *lLabel;
@property (weak) IBOutlet NSWindow *wSubWindow;

@property (weak) IBOutlet NSMenuItem *miFileName;
@property (weak) IBOutlet NSMenuItem *miSeparator;

@property (weak) IBOutlet NSTableView *tvApplications;

@property (weak) IBOutlet NSArrayController *acArrayController;

- (IBAction)fileNameSelected:(id)sender;

+ (void)showMissionControl;
+ (void)showApplicationWindows;
+ (void)showDesktop;
+ (void)showDashboard;
+ (void)showLaunchpad;
+ (void)sleep;

@end
