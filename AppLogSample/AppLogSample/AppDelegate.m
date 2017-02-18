//
//  AppDelegate.m
//  AppLogSample
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import "AppDelegate.h"
#import <AppLog/AppLog.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    APP_LOG_INFO(@"Hello World");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}
- (IBAction)InfoButtonClicked:(id)sender
{
    APP_LOG_INFO(@"Info Activated");
}

- (IBAction)ActionButtonClicked:(id)sender
{
    APP_LOG_INFO(@"Action Activated");
}

@end
