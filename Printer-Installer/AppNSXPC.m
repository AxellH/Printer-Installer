//
//  AppNSXPC.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AppNSXPC.h"

@implementation AppNSXPC

+(void)addPrinter:(Printer*)printer{
    NSLog(@"Adding printer: %@",printer.description);
    
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxy] addPrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [AppProgress showErrorAlert:error onWindow:[[NSApplication sharedApplication]mainWindow]];
             }
         }];
         [helperXPCConnection invalidate];
     }];
}

+(void)removePrinter:(Printer*)printer{
    NSLog(@"Removing printer: %@",printer.description);
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxy] removePrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [AppProgress showErrorAlert:error onWindow:[[NSApplication sharedApplication]mainWindow]];
                 
             }
         }];
         [helperXPCConnection invalidate];
     }];
}

+(void)tellHelperToQuit{
    // Send a message to the helper tool telling it to call it's quitHelper method.
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    [helperXPCConnection resume];
    
    [[helperXPCConnection remoteObjectProxy] quitHelper];
}


@end
