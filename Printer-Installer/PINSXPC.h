//
//  PINSXPC.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Interfaces.h"
#import "Server.h"
#import "PIPannel.h"

@interface PINSXPC : NSObject

+(void)addPrinter:(NSDictionary*)printer;
+(void)removePrinter:(NSDictionary*)printer;
+(void)tellHelperToQuit;

@end