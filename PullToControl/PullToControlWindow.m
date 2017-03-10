//
//  PullToControlWindow.m
//  PullToControl
//
//  Created by HatanoKenta on 2017/02/22.
//  Copyright © 2017年 Nita. All rights reserved.
//

#import "PullToControlWindow.h"

@implementation PullToControlWindow {
    
}

NSRect originalFrame;
BOOL mousePressed = NO;
CGFloat totalScroll = 0.0f;

- (void)awakeFromNib {
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
    
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self.contentView frame] options:NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect | NSTrackingActiveAlways owner:self userInfo:nil];
    [self.contentView addTrackingArea:area];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"mouseDown");
    originalFrame = self.frame;
    mousePressed = YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSLog(@"mouseUp");
    NSInteger x = theEvent.locationInWindow.x;
    NSInteger y = theEvent.locationInWindow.y + self.frame.origin.y;
    
    NSInteger displayHeight = [NSScreen mainScreen].frame.size.height;
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.0]];
    [self setFrame:originalFrame display:YES];
    self.lLabel.stringValue = @"";
    mousePressed = NO;
    
    if (x < 0) {
        [PullToControlWindow moveToRightSpace];
    } else if (x > 128) {
        [PullToControlWindow moveToLeftSpace];
    } else if (y < 4) {
        [PullToControlWindow sleep];
    } else if (y < displayHeight / 3) {
        [PullToControlWindow showDashboard];
    } else if (y < displayHeight * 2 / 3) {
        [PullToControlWindow showLaunchpad];
    } else if (y < displayHeight - 24) {
        [PullToControlWindow showMissionControl];
    } else {
        self.lLabel.stringValue = @"";
    }
}

- (void)mouseMoved:(NSEvent *)theEvent {
    NSLog(@"mouseMoved");
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSRect newFrame = self.frame;
    
    NSInteger displayHeight = [NSScreen mainScreen].frame.size.height;
    
    NSInteger newHeight = (displayHeight - theEvent.locationInWindow.y - self.frame.origin.y) / 4;
    NSInteger newY = displayHeight - newHeight;
    if (newY > displayHeight - 8) {
        newY = displayHeight - 8;
        newHeight = 8;
    }
    
    newFrame.origin.y = newY;
    newFrame.size.height = newHeight;
    
    [self setFrame:newFrame display:YES];
    
    NSInteger x = theEvent.locationInWindow.x;
    NSInteger y = theEvent.locationInWindow.y + self.frame.origin.y;
    if (x < 0) {
        self.lLabel.stringValue = @"Right space";
    } else if (x > 128) {
        self.lLabel.stringValue = @"Left space";
    } else if (y < 4) {
        self.lLabel.stringValue = @"Sleep";
    } else if (y < displayHeight / 3) {
        self.lLabel.stringValue = @"Dashboard";
    } else if (y < displayHeight * 2 / 3) {
        self.lLabel.stringValue = @"Launchpad";
    } else if (y < displayHeight - 24) {
        self.lLabel.stringValue = @"Mission Control";
    } else {
        self.lLabel.stringValue = @"";
    }
    
    NSLog(@"mouseDragged");
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"mouseEntered");
    if (!mousePressed) {
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    NSLog(@"mouseExited");
    if (!mousePressed) {
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.0]];
    }
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    totalScroll += theEvent.deltaY;
    NSLog(@"%f", totalScroll);
    if (totalScroll > 20) {
        [PullToControlWindow showPrevApp];
        totalScroll -= 20;
    }
    if (totalScroll < -20) {
        [PullToControlWindow showNextApp];
        totalScroll += 20;
    }
}

+ (void)moveToLeftSpace {
    NSDictionary *asErrDic = nil;
    NSAppleScript *as = [ [ NSAppleScript alloc ]
                         initWithSource : @"tell application \"System Events\" to key code {123} using control down" ];
    [ as executeAndReturnError : &asErrDic ];
}

+ (void)moveToRightSpace {
    NSDictionary *asErrDic = nil;
    NSAppleScript *as = [ [ NSAppleScript alloc ]
                         initWithSource : @"tell application \"System Events\" to key code {124} using control down" ];
    [ as executeAndReturnError : &asErrDic ];
}

+ (void)showMissionControl {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";
    task.arguments = @[@"-a", @"mission control"];
    [task launch];
}

+ (void)showDashboard {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";
    task.arguments = @[@"-a", @"dashboard"];
    [task launch];
}

+ (void)showLaunchpad {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";
    task.arguments = @[@"-a", @"launchpad"];
    [task launch];
}

+ (void)sleep {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/pmset";
    task.arguments = @[@"sleepnow"];
    [task launch];
}

+ (void)showNextApp {
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    NSMutableArray *appsFiltered = [[NSMutableArray alloc] init];
    for (NSRunningApplication *app in apps) {
        if (app.activationPolicy != NSApplicationActivationPolicyRegular){
            continue;
        }
        [appsFiltered addObject:app];
    }
    
    [appsFiltered sortUsingComparator:^NSComparisonResult(NSRunningApplication *app1, NSRunningApplication *app2) {
        return [[app1 localizedName] compare:[app2 localizedName]];
    }];
    
    NSInteger appIndex = 0;
    NSInteger i = 0;
    for (NSRunningApplication *app in appsFiltered) {
        if (app.isActive) {
            appIndex = i;
            break;
        }
        i++;
    }
    
    appIndex++;
    if (appIndex >= [appsFiltered count]) {
        appIndex = 0;
    }
    
    [(NSRunningApplication *)[appsFiltered objectAtIndex:appIndex] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

+ (void)showPrevApp {
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    NSMutableArray *appsFiltered = [[NSMutableArray alloc] init];
    for (NSRunningApplication *app in apps) {
        if (app.activationPolicy != NSApplicationActivationPolicyRegular){
            continue;
        }
        [appsFiltered addObject:app];
    }
    
    [appsFiltered sortUsingComparator:^NSComparisonResult(NSRunningApplication *app1, NSRunningApplication *app2) {
        return [[app1 localizedName] compare:[app2 localizedName]];
    }];
    
    NSInteger appIndex = 0;
    NSInteger i = 0;
    for (NSRunningApplication *app in appsFiltered) {
        if (app.isActive) {
            appIndex = i;
            break;
        }
        i++;
    }
    
    appIndex--;
    if (appIndex < 0) {
        appIndex += [appsFiltered count];
    }
    
    [(NSRunningApplication *)[appsFiltered objectAtIndex:appIndex] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

@end
