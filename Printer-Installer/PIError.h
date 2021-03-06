//
//  PIError.h
//  Printer-Installer
//
//  Created by Eldon on 11/2/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString* const PIDomain;
extern NSString* const PINoSharedGroups;
extern NSString* const PIIncorrectURL;
extern NSString* const PIIncorrectURLAlt;

typedef NS_ENUM(NSInteger, PIErrorCode){
    kPIErrorSuccess = 0,
    kPIErrorServerNotFound = 1000,
    kPIErrorCouldNotAddLoginItem,
    kPIErrorCouldNotInstallHelper,
};

@interface PIError : NSObject
+(BOOL) errorWithCode:(PIErrorCode)code error:(NSError **)error;

#ifdef _APPKITDEFINES_H
+(void) presentError:(NSError*)error;

+(void) presentErrorWithCode:(PIErrorCode)code
                    delegate:(id)sender
          didPresentSelector:(SEL)selector;

+(void) presentError:(NSError *)error
            delegate:(id)sender
  didPresentSelector:(SEL)selector;
#endif

@end
