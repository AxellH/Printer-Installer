//
//  PINSXPC.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PINSXPC.h"
#import "SMJobBlesser.h"
#import "PIAlert.h"

@implementation PINSXPC

#pragma mark - Initializers
-(id)initWithMachServiceName:(NSString *)name options:(NSXPCConnectionOptions)options{
    self = [super initWithMachServiceName:name options:options];
    if (self) {
        self.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
        [self resume];
    }
    return self;
}

-(id)initConnection{
    self = [self initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    return self;
}


-(void)addPrinter:(Printer*)printer reply:(void (^)(NSError* error))reply{
    [[self remoteObjectProxyWithErrorHandler:^(NSError *error) {
        if(error)NSLog(@"add printer xpc error: %@",error.localizedDescription);
    }] addPrinter:printer withReply:^(NSError *error) {
        reply(error);
        [self invalidate];
    }];
}

-(void)removePrinter:(Printer*)printer reply:(void (^)(NSError* error))reply{
    [[self remoteObjectProxyWithErrorHandler:^(NSError *error) {
        if(error)NSLog(@"remove printer xpc error: %@",error.localizedDescription);
    }] removePrinter:printer withReply:^(NSError *error) {
        reply(error);
        [self invalidate];
    }];
}


+(void)changePrinterAvaliablily:(Printer*)printer add:(BOOL)added reply:(void (^)(NSError *error))reply{
    PINSXPC* connection = [[PINSXPC alloc]initConnection];
    if(added){
        [connection addPrinter:printer reply:^(NSError *error) {
            reply(error);
        }];
    }else{
        [connection removePrinter:printer reply:^(NSError *error) {
            reply(error);
        }];
    }
}


+(void)installGlobalLoginItem{
    PINSXPC* connection = [[PINSXPC alloc]initConnection];
    [[connection remoteObjectProxy] helperInstallLoginItem:[[NSBundle mainBundle] bundleURL] withReply:^(NSError *error) {
        [connection invalidate];
    }];
}

+(void)tellHelperToQuit{
    // Send a message to the helper tool telling it to call it's quitHelper method.
    PINSXPC* connection = [[PINSXPC alloc]initConnection];
    [[connection remoteObjectProxy] quitHelper:^(BOOL success) {
        [connection invalidate];
    }];
}

+(void)uninstallHelper{
    PINSXPC* connection = [[PINSXPC alloc]initConnection];
    [[connection remoteObjectProxy] uninstall:^(NSError * error) {
        [connection invalidate];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(error){
                [NSApp presentError:error];
            }else{
                [JobBlesser removeHelperWithLabel:kHelperName];
                [[NSApplication sharedApplication]activateIgnoringOtherApps:YES];
                [PIAlert showAlert:@"Helper Tool Removed"
                   withDescription:@"we've removed all files associated with printer installer. we will now quit."
                    didEndSelector:@selector(setupDidRemoveHelperTool:)];
            }
        }];
    }];
}


@end
