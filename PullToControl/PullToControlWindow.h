//
//  PullToControlWindow.h
//  PullToControl
//
//  Created by HatanoKenta on 2017/02/22.
//  Copyright © 2017年 Nita. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PullToControlWindow : NSWindow <NSWindowDelegate>

@property (weak) IBOutlet NSTextField *lLabel;
@property (weak) IBOutlet NSWindow *wSubWindow;

+ (void)showMissionControl;
+ (void)showDashboard;
+ (void)showLaunchpad;
+ (void)sleep;

@end
