//
//  AppDelegate.m
//  PullToControl
//
//  Created by HatanoKenta on 2017/02/22.
//  Copyright © 2017年 Nita. All rights reserved.
//

#import "AppDelegate.h"
#import "PullToControlWindow.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSApplication sharedApplication] setPresentationOptions: NSApplicationPresentationAutoHideMenuBar];
    self.window.level = NSPopUpMenuWindowLevel;
    
    NSRect newFrame = self.window.frame;
    newFrame.origin.y = [NSScreen mainScreen].frame.size.height - newFrame.size.height;
    [self.window setFrame:newFrame display:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)showMissionControl:(id)sender {
    [PullToControlWindow showMissionControl];
}

- (IBAction)showApplicationWidows:(id)sender {
    [PullToControlWindow showApplicationWindows];
}

- (IBAction)showDesktop:(id)sender {
    [PullToControlWindow showDesktop];
}

- (IBAction)showDashboard:(id)sender {
    [PullToControlWindow showDashboard];
}

- (IBAction)showLaunchpad:(id)sender {
    [PullToControlWindow showLaunchpad];
}

- (IBAction)sleep:(id)sender {
    [PullToControlWindow sleep];
}

- (IBAction)quitPullToControl:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

@end
