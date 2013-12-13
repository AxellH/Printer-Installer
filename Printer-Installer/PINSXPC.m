//
//  PINSXPC.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PINSXPC.h"
#import "SMJobBlesser.h"

@implementation PINSXPC
+(void)changePrinterAvaliablily:(Printer*)printer
                       menuItem:(NSMenuItem*)menuItem
                            add:(BOOL)added{
    !added ?[self addPrinter:printer menuItem:menuItem]:
            [self removePrinter:printer menuItem:menuItem];
}

+(void)addPrinter:(Printer*)printer menuItem:(NSMenuItem*)menuItem{
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }] addPrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [NSApp presentError:error];
             }else{
                 [menuItem setState:NSOnState];
             }
         }];
         [helperXPCConnection invalidate];
     }];
}

+(void)removePrinter:(Printer*)printer menuItem:(NSMenuItem*)menuItem{
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        NSLog(@"Error: %@",error.localizedDescription);
    }] removePrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [NSApp presentError:error];
             }else{
                 [menuItem setState:NSOffState];
             }
         }];
         [helperXPCConnection invalidate];
     }];
}

+(void)installGlobalLoginItem{
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    [helperXPCConnection resume];
    
    [[helperXPCConnection remoteObjectProxy] helperInstallLoginItem:[[NSBundle mainBundle] bundleURL]];
}

+(void)tellHelperToQuit{
    // Send a message to the helper tool telling it to call it's quitHelper method.
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    [helperXPCConnection resume];
    
    [[helperXPCConnection remoteObjectProxy] quitHelper];
}

+(void)uninstallHelper{
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    [helperXPCConnection resume];
    
    [[helperXPCConnection remoteObjectProxy] uninstall:^(NSError * error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(error){
                NSLog(@"error: %@", error.localizedDescription);
            }else{
                [JobBlesser removeHelperWithLabel:kHelperName];
                [[NSApplication sharedApplication]activateIgnoringOtherApps:YES];
                [NSApp presentError:[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Helper Tool and associated files have been removed.  We will now quit"}] modalForWindow:NULL delegate:[NSApp delegate]
                 didPresentSelector:@selector(setupDidRemoveHelperTool:) contextInfo:nil];
            }
        }];
    }];
}


@end
