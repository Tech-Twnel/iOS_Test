//
//  KeyChaiHandler.h
//  Twnel Apps
//  Santiago Castillo <santiago@twnel.com>
//
//  Created on 05/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//
//  This class manages the storage of passwords inside the Keychain.
//  Digital digest of the passwords are stored using the keys defined on Constants.h

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Constants.h"

@interface KeyChaiHandler : NSObject

// Store the given password inside the Keychain.
// Digital digest of the password is stored
+ (BOOL)storePassword:(NSString *)password;

// Compares the given password with the password stored inside the keychain.
+ (BOOL)isEqualToStoredPassword:(NSString *)password;

@end
