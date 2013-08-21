//
//  main.m
//  printer-installer-helper
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"

static const NSTimeInterval kHelperCheckInterval = 1.0; // how often to check whether to quit


int main(int argc, const char *argv[])
{
    // LaunchServices automatically registers a mach service of the same
	// name as our bundle identifier.  This is the same as MachService key in
    // the SMJobBlessHelper-Launchd.plist
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:bundleID];
    
    // Create the delegate of the listener.
    helper *sharedAgent = [helper new];
    listener.delegate = sharedAgent;
    
    // Begin accepting incoming connections.
	// For mach service listeners, the resume method returns immediately so
	// we need to start our event loop manually.
    [listener resume];
    NSRunLoop * helperLoop = [NSRunLoop currentRunLoop];
    
    while (!sharedAgent.helperToolShouldQuit)
    {
        [helperLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kHelperCheckInterval]];
    }
	return 0;
}
