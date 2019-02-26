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
NSMutableArray *appsFiltered;
NSInteger appIndex = 0;
NSTimer *appShowingTimer = nil;

- (void)awakeFromNib {
    self.wSubWindow.level = NSPopUpMenuWindowLevel;
    self.wSubWindow.opaque = NO;
    [self.wSubWindow setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
    self.wSubWindow.hidesOnDeactivate = NO;
    
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
    
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self.contentView frame] options:NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect | NSTrackingActiveAlways owner:self userInfo:nil];
    [self.contentView addTrackingArea:area];
    
    NSArray *parrTypes = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
    [self registerForDraggedTypes:parrTypes];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"mouseDown");
    [self activateCurrentApp];
    [self.wSubWindow close];
    originalFrame = self.frame;
    mousePressed = YES;
}

- (void)otherMouseDown:(NSEvent *)theEvent {
    NSLog(@"middleClick");
    self.wSubWindow.hidesOnDeactivate = NO;
    [self.wSubWindow makeKeyAndOrderFront:self];
    [self activateCurrentApp];
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
    
    if (y < 4) {
        [PullToControlWindow sleep];
    } else if (x < 0) {
        [PullToControlWindow moveToRightSpace];
    } else if (x > 128) {
        [PullToControlWindow moveToLeftSpace];
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
    if (y < 4) {
        self.lLabel.stringValue = @"Sleep";
    } else if (x < 0) {
        self.lLabel.stringValue = @"Right space";
    } else if (x > 128) {
        self.lLabel.stringValue = @"Left space";
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
    [self searchCurrentIndex];
    if (!mousePressed) {
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
        if (!appShowingTimer) {
            appShowingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(showAppNames:) userInfo:nil repeats:NO];
        }
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    NSLog(@"mouseExited");
    if (!mousePressed) {
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.0]];
        [self.wSubWindow close];
        
        [self activateCurrentApp];
        if (appShowingTimer && [appShowingTimer isValid]) {
            [appShowingTimer invalidate];
            appShowingTimer = nil;
        }
    }
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if (!self.wSubWindow.visible) {
        self.wSubWindow.hidesOnDeactivate = NO;
        [self.wSubWindow makeKeyAndOrderFront:self];
    }
    
    totalScroll += theEvent.deltaY;
    NSLog(@"%f", totalScroll);
    if (totalScroll > 4) {
        [self showPrevApp];
        totalScroll = 0;
    }
    if (totalScroll < -4) {
        [self showNextApp];
        totalScroll = 0;
    }
}

+ (void)moveToLeftSpace {
    NSDictionary *asErrDic = nil;
    NSAppleScript *as = [ [ NSAppleScript alloc ]
                         initWithSource : @"tell application \"System Events\" to key code {123} using control down" ];
    [ as executeAndReturnError : &asErrDic ];
    if (asErrDic && [asErrDic count] > 0) {
        NSLog(@"%@", [asErrDic description]);
    }
}

+ (void)moveToRightSpace {
    NSDictionary *asErrDic = nil;
    NSAppleScript *as = [ [ NSAppleScript alloc ]
                         initWithSource : @"tell application \"System Events\" to key code {124} using control down" ];
    [ as executeAndReturnError : &asErrDic ];
    if (asErrDic && [asErrDic count] > 0) {
        NSLog(@"%@", [asErrDic description]);
    }
}

+ (void)showMissionControl {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";
    task.arguments = @[@"-a", @"mission control"];
    [task launch];
}

+ (void)showApplicationWindows {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";
    task.arguments = @[@"-a", @"mission control", @"--args", @"2"];
    [task launch];
}

+ (void)showDesktop {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";
    task.arguments = @[@"-a", @"mission control", @"--args", @"1"];
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

- (void)searchCurrentIndex {
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    appsFiltered = [[NSMutableArray alloc] init];
    for (NSRunningApplication *app in apps) {
        if (app.activationPolicy != NSApplicationActivationPolicyRegular){
            continue;
        }
        [appsFiltered addObject:app];
    }
    
    [appsFiltered sortUsingComparator:^NSComparisonResult(NSRunningApplication *app1, NSRunningApplication *app2) {
        return [[app1 localizedName] compare:[app2 localizedName]];
    }];
    
    appIndex = 0;
    NSInteger i = 0;
    for (NSRunningApplication *app in appsFiltered) {
        if (app.isActive) {
            appIndex = i;
            break;
        }
        i++;
    }
    
    [self reloadApplicationsTableView];
    
    NSRect newRect = self.wSubWindow.frame;
    NSInteger originalHeight = newRect.size.height;
    newRect.size.height = [appsFiltered count] * 24;
    newRect.origin.y = newRect.origin.y - (newRect.size.height - originalHeight);
    [self.wSubWindow setFrame:newRect display:!self.tvApplications.isHidden];
}

- (void)showNextApp {
    NSLog(@"showNextApp");
    appIndex++;
    if (appIndex >= [appsFiltered count]) {
        appIndex = 0;
    }
    
    // [(NSRunningApplication *)[appsFiltered objectAtIndex:appIndex] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    [self reloadApplicationsTableView];
}

- (void)showPrevApp {
    NSLog(@"showPrevApp");
    appIndex--;
    if (appIndex < 0) {
        appIndex += [appsFiltered count];
    }
    
    // [(NSRunningApplication *)[appsFiltered objectAtIndex:appIndex] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    [self reloadApplicationsTableView];
}

- (void)showAppNames:(NSTimer *)timer {
    self.wSubWindow.hidesOnDeactivate = NO;
    [self.wSubWindow makeKeyAndOrderFront:self];
    appShowingTimer = nil;
}

- (void)activateCurrentApp {
    if (![(NSRunningApplication *)[appsFiltered objectAtIndex:appIndex] isActive]) {
        [(NSRunningApplication *)[appsFiltered objectAtIndex:appIndex] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    }
}

- (IBAction)fileNameSelected:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:self.filePath];
}

- (void)reloadApplicationsTableView {
    while ([self.acArrayController.arrangedObjects count] > 0) {
        [self.acArrayController removeObjectAtArrangedObjectIndex:0];
    }
    
    NSInteger index = 0;
    for (NSRunningApplication *app in appsFiltered) {
        NSMutableDictionary *dict = [@{@"title": [app localizedName],
                                       @"color": app.isHidden ? [NSColor grayColor] : [NSColor whiteColor]} mutableCopy];
        [self.acArrayController addObject:dict];
        index++;
    }
    [self.acArrayController rearrangeObjects];
    [self.acArrayController setSelectionIndex:appIndex];
    
    [self.tvApplications reloadData];
}

#pragma mark NSDraggingDestination

BOOL mouseWithin = NO;

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSLog(@"draggingEntered : %@", [sender description]);
    mouseWithin = YES;
    
    return NSDragOperationGeneric;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender {
    NSLog(@"draggingEnded : %@", [sender description]);
    
    NSPasteboard *poPasteBd = [sender draggingPasteboard];
    NSArray *parrFiles = [poPasteBd propertyListForType:NSFilenamesPboardType];
    NSLog(@"parrFiles : %@", [parrFiles description]);
    
    if (mouseWithin) {
        self.filePath = parrFiles[0];
        self.miFileName.title = [parrFiles[0] lastPathComponent];
        self.miFileName.hidden = NO;
        self.miSeparator.hidden = NO;
    }
    mouseWithin = NO;
    
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    mouseWithin = NO;
    NSLog(@"draggingExited : %@", [sender description]);
    
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [appsFiltered count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [appsFiltered[row] localizedName];
}

@end
