//  Twnel Apps
//  Santiago Castillo <santiago@twnel.com>
//
//  Created on 05/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//
//  This class manages the storage of passwords inside the Keychain.
//  Digital digest of the passwords are stored using the keys defined on Constants.h
//

#import "KeyChaiHandler.h"

// Used to give strength to digital digests.
#define APP_HASH @"3548253696"

@implementation KeyChaiHandler

// Set the dictionary query that will be used to retreive items from the keychain.
+ (NSMutableDictionary *)setupSearchDirectoryForIdentifier:(NSString *)identifier{
    // Get app identifier.
    id appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    // Setup dictionary to access keychain.
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    // Specify we are using a password (rather than a certificate, internet password, etc).
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Uniquely identify this keychain accessor.
    [searchDictionary setObject:appName forKey:(__bridge id)kSecAttrService];
    
    // Uniquely identify the account who will be accessing the keychain.
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    
    return searchDictionary;
}

// Return an item from the keychain given the identifier.
+ (NSData *)searchKeychainMatchingIdentifier:(NSString *)identifier{
    
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    // Limit search results to one.
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Specify we want NSData/CFData returned.
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    // Search.
    NSData *result = nil;
    CFTypeRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    if (status == noErr) {
        result = (__bridge_transfer NSData *)foundDict;
    } else {
        result = nil;
    }
    
    return result;
}

// Return item from the keychain as an NSString given the identifier.
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier{
    NSData *valueData = [self searchKeychainMatchingIdentifier:identifier];
    if (valueData) {
        NSString *value = [[NSString alloc] initWithData:valueData
                                                encoding:NSUTF8StringEncoding];
        return value;
    } else {
        return nil;
    }
}

// Insert a value into the keychain aattached to the given identifier.
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier{
    
    NSMutableDictionary *dictionary = [self setupSearchDirectoryForIdentifier:identifier];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:valueData forKey:(__bridge id)kSecValueData];
    
    // Protect the keychain entry so it's only valid when the device is unlocked.
    [dictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    // Add.
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    // If the addition was successful, return. Otherwise, attempt to update existing key or quit (return NO).
    if (status == errSecSuccess) {
        return YES;
    } else if (status == errSecDuplicateItem){
        return [self updateKeychainValue:value forIdentifier:identifier];
    } else {
        return NO;
    }
}

// Update the value of an existing item on the keychain.
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier{
    
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:valueData forKey:(__bridge id)kSecValueData];
    
    // Update.
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) {
        return YES;
    } else {
        return NO;
    }
}


+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    CFDictionaryRef dictionary = (__bridge CFDictionaryRef)searchDictionary;
    
    //Delete.
    SecItemDelete(dictionary);
}

// Return a digital digest assosiated with the given password.
// App hash is used to construct the digest.
+ (NSString *)secSHA256DigestHash:(NSString *)password{
    
    // Add app hash to strenghen the digital digest.
    NSString *computedHashString = [password stringByAppendingString:APP_HASH];
    
    // Hash using SHA256.
    NSString *finalHash = [self computeSHA256DigestForString:computedHashString];
    
    return finalHash;
}

// Compute a SHA256 hash for the given string.
+ (NSString *)computeSHA256DigestForString:(NSString*)input{
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    

    // Hash method, it takes in the data, how much data, and then output format.
    CC_SHA256(data.bytes, data.length, digest);
    
    // Setup Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

// Compares the given password with the password stored on the keychain.
+ (BOOL)isEqualToStoredPassword:(NSString *)password{
    if ([[self keychainStringFromMatchingIdentifier:JABBER_PASSWORD] isEqualToString:[self secSHA256DigestHash:password]]) {
        return YES;
    } else {
        return NO;
    }
}

// Store the given password.
// Digital digest of the password is stored.
+ (BOOL)storePassword:(NSString *)password{
    // Hash paswword before storing.
    NSString *hash = [self secSHA256DigestHash:password];
    
    // Store password inside keychain.
    return [self createKeychainValue:hash forIdentifier:JABBER_PASSWORD];
}

@end
