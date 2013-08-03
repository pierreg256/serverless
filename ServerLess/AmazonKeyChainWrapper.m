/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AmazonKeyChainWrapper.h"
#import <AWSRuntime/AWSRuntime.h>

NSString *kKeychainUsernameIdentifier;

@implementation AmazonKeyChainWrapper

+(void)initialize 
{
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;

    kKeychainUsernameIdentifier = [NSString stringWithFormat:@"%@.USERNAME", bundleID] ; 
}

+(void)storeUsername:(NSString *)theUsername
{
    [AmazonKeyChainWrapper storeValueInKeyChain:theUsername forKey:kKeychainUsernameIdentifier];    
}

+(NSString *)username
{
    return [AmazonKeyChainWrapper getValueFromKeyChain:kKeychainUsernameIdentifier];
}

+(NSString *)getValueFromKeyChain:(NSString *)key
{
    AMZLogDebug(@"Get Value for KeyChain key:[%@]", key);

    NSMutableDictionary *queryDictionary = [[NSMutableDictionary alloc] init] ;

    [queryDictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)CFBridgingRelease(kSecAttrGeneric)];
    [queryDictionary setObject:(id) kCFBooleanTrue forKey:(id)CFBridgingRelease(kSecReturnAttributes)];
    [queryDictionary setObject:(id) CFBridgingRelease(kSecMatchLimitOne) forKey:(id)CFBridgingRelease(kSecMatchLimit)];
    [queryDictionary setObject:(id) kCFBooleanTrue forKey:(id)CFBridgingRelease(kSecReturnData)];
    [queryDictionary setObject:(id) CFBridgingRelease(kSecClassGenericPassword) forKey:(id)CFBridgingRelease(kSecClass)];

    //    NSDictionary *returnedDictionary = [[NSMutableDictionary alloc] init] ;
    CFDataRef returnedDictionary = nil; 
    OSStatus     keychainError       = SecItemCopyMatching((CFDictionaryRef)CFBridgingRetain(queryDictionary), (CFTypeRef *)&returnedDictionary);
    if (keychainError == errSecSuccess)
    {
        //        NSData *rawData = [returnedDictionary objectForKey:(id)CFBridgingRelease(kSecValueData)];
        NSData* tmpData = (__bridge_transfer NSData*)returnedDictionary;
        NSData* rawData = [((NSDictionary*)tmpData) objectForKey:(id)CFBridgingRelease(kSecValueData)];
        NSString* returnString = [[NSString alloc] initWithBytes:[rawData bytes] length:[rawData length] encoding:NSUTF8StringEncoding] ;
        AMZLogDebug(@"found value: %@, for key :%@", returnString, key);
        return returnString;
    }
    else
    {
        AMZLogDebug(@"Unable to fetch value for keychain key '%@', Error Code: %ld", key, keychainError);
        return nil;
    }
}

+(void)storeValueInKeyChain:(NSString *)value forKey:(NSString *)key
{
    AMZLogDebug(@"Storing value:[%@] in KeyChain as key:[%@]", value, key);

    NSMutableDictionary *keychainDictionary = [[NSMutableDictionary alloc] init] ;
    [keychainDictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)CFBridgingRelease(kSecAttrGeneric)];
    [keychainDictionary setObject:(id) CFBridgingRelease(kSecClassGenericPassword) forKey:(id)CFBridgingRelease(kSecClass)];
    [keychainDictionary setObject:[value dataUsingEncoding:NSUTF8StringEncoding]    forKey:(id)CFBridgingRelease(kSecValueData)];
    [keychainDictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)CFBridgingRelease(kSecAttrAccount)];
    [keychainDictionary setObject:(id) CFBridgingRelease(kSecAttrAccessibleWhenUnlockedThisDeviceOnly) forKey:(id)CFBridgingRelease(kSecAttrAccessible)];

    OSStatus keychainError = SecItemAdd((CFDictionaryRef)CFBridgingRetain(keychainDictionary), NULL);
    if (keychainError == errSecDuplicateItem) {
        SecItemDelete((CFDictionaryRef)CFBridgingRetain(keychainDictionary));
        keychainError = SecItemAdd((CFDictionaryRef)CFBridgingRetain(keychainDictionary), NULL);
    }
    
    if (keychainError != errSecSuccess) {
        AMZLogDebug(@"Error saving value to keychain key '%@', Error Code: %ld", key, keychainError);
    }
}

+(OSStatus)wipeKeyChain
{
    OSStatus keychainError = SecItemDelete((CFDictionaryRef)CFBridgingRetain([AmazonKeyChainWrapper createKeychainDictionaryForKey : kKeychainUsernameIdentifier]));
    if(keychainError != errSecSuccess && keychainError != errSecItemNotFound)
    {
        AMZLogDebug(@"Keychain Key: kKeychainUsernameIdentifier, Error Code: %ld", keychainError);
        return keychainError;
    }
    
    return errSecSuccess;
}

+(NSMutableDictionary *)createKeychainDictionaryForKey:(NSString *)key
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init] ;

    [dictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)CFBridgingRelease(kSecAttrGeneric)];
    [dictionary setObject:(id) CFBridgingRelease(kSecClassGenericPassword) forKey:(id)CFBridgingRelease(kSecClass)];
    [dictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)CFBridgingRelease(kSecAttrAccount)];
    [dictionary setObject:(id) CFBridgingRelease(kSecAttrAccessibleWhenUnlockedThisDeviceOnly) forKey:(id)CFBridgingRelease(kSecAttrAccessible)];

    return dictionary;
}

@end
