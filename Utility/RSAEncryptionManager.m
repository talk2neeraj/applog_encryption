//
//  RSAEncryptionManager.m
//  LogDecryptor
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import "RSAEncryptionManager.h"
#import <Security/Security.h>
#include <CoreServices/CoreServices.h>

@interface RSAEncryptionManager()
{
    SecKeyRef _secKey;
}

@end

@implementation RSAEncryptionManager

- (instancetype)initWithPublicKeyData:(NSData *)data
{
    self = [super init];
    
    if (!self || !data.length)
    {
        NSLog(@"Could not read public RSA key");
        return nil;
    }
    
    SecExternalFormat format = kSecFormatOpenSSL;
    SecExternalItemType itemType = kSecItemTypePublicKey;
    CFArrayRef items = NULL;
    
    OSStatus status = SecItemImport((__bridge CFDataRef)data, NULL, &format, &itemType, (SecItemImportExportFlags)0, NULL, NULL, &items);
    if (status != errSecSuccess || !items)
    {
        if (items)
        {
            CFRelease(items);
        }
        NSLog(@"Public RSA key could not be imported: %d", status);
        return nil;
    }
    
    if (format == kSecFormatOpenSSL && itemType == kSecItemTypePublicKey && CFArrayGetCount(items) == 1)
    {
        _secKey = (SecKeyRef)CFRetain(CFArrayGetValueAtIndex(items, 0));
    }
    
    CFRelease(items);
    
    return self;
}

- (instancetype)initWithPrivateKeyData:(NSData *)data
{
    self = [super init];
    
    if (!self || !data.length)
    {
        NSLog(@"Could not read public RSA key");
        return nil;
    }
    
    SecExternalFormat format = kSecFormatOpenSSL;
    SecExternalItemType itemType = kSecItemTypePrivateKey;
    CFArrayRef items = NULL;
    
    OSStatus status = SecItemImport((__bridge CFDataRef)data, NULL, &format, &itemType, (SecItemImportExportFlags)0, NULL, NULL, &items);
    if (status != errSecSuccess || !items)
    {
        if (items)
        {
            CFRelease(items);
        }
        NSLog(@"Public RSA key could not be imported: %d", status);
        return nil;
    }
    
    if (format == kSecFormatOpenSSL && itemType == kSecItemTypePrivateKey && CFArrayGetCount(items) == 1) {
        
        _secKey = (SecKeyRef)CFRetain(CFArrayGetValueAtIndex(items, 0));
    }
    
    CFRelease(items);
    
    return self;
}

-(NSData*) encryptData:(NSData*) data
{
    if(_secKey == nil) return nil;
    
    __block SecGroupTransformRef group = SecTransformCreateGroupTransform();
    __block SecTransformRef dataReadTransform = NULL;
    __block SecTransformRef dataEncryptTransform = NULL;
    __block SecTransformRef dataVerifyTransform = NULL;
    __block CFErrorRef error = NULL;
    
    NSData* (^cleanup)(void) = ^{
        if (group) CFRelease(group);
        if (dataReadTransform) CFRelease(dataReadTransform);
        if (dataEncryptTransform) CFRelease(dataEncryptTransform);
        if (dataVerifyTransform) CFRelease(dataVerifyTransform);
        if (error) CFRelease(error);
        return (NSData*)nil;
    };
    
    NSInputStream *stream = [[NSInputStream alloc] initWithData: data];
    
    dataReadTransform = SecTransformCreateReadTransformWithReadStream((__bridge CFReadStreamRef)stream);
    if (!dataReadTransform)
    {
        NSLog(@"File containing update archive could not be read (failed to create SecTransform for input stream)");
        return cleanup();
    }
    
    dataEncryptTransform = SecEncryptTransformCreate(_secKey, &error);
    if (!dataEncryptTransform) {
        return cleanup();
    }
    
    
    SecTransformConnectTransforms(dataReadTransform, kSecTransformOutputAttributeName, dataEncryptTransform, kSecTransformInputAttributeName, group, &error);
    if (error) {
        NSLog(@"%@", error);
        return cleanup();
    }
    
    
    NSData *result = CFBridgingRelease(SecTransformExecute(group, &error));
    if (error) {
        NSLog(@"RSA signature verification failed: %@", error);
        return cleanup();
    }
    
    cleanup();
    return result;
}

-(NSData*) decryptData:(NSData*) data
{
    if(_secKey == nil) return nil;
    
    __block SecGroupTransformRef group = SecTransformCreateGroupTransform();
    __block SecTransformRef dataReadTransform = NULL;
    __block SecTransformRef dataEncryptTransform = NULL;
    __block SecTransformRef dataVerifyTransform = NULL;
    __block CFErrorRef error = NULL;
    
    NSData* (^cleanup)(void) = ^{
        if (group) CFRelease(group);
        if (dataReadTransform) CFRelease(dataReadTransform);
        if (dataEncryptTransform) CFRelease(dataEncryptTransform);
        if (dataVerifyTransform) CFRelease(dataVerifyTransform);
        if (error) CFRelease(error);
        return (NSData*)nil;
    };
    
    NSInputStream *stream = [[NSInputStream alloc] initWithData: data];
    
    dataReadTransform = SecTransformCreateReadTransformWithReadStream((__bridge CFReadStreamRef)stream);
    if (!dataReadTransform)
    {
        NSLog(@"File containing update archive could not be read (failed to create SecTransform for input stream)");
        return cleanup();
    }
    
    dataEncryptTransform = SecDecryptTransformCreate(_secKey, &error);
    if (!dataEncryptTransform) {
        return cleanup();
    }
    
    
    SecTransformConnectTransforms(dataReadTransform, kSecTransformOutputAttributeName, dataEncryptTransform, kSecTransformInputAttributeName, group, &error);
    if (error) {
        NSLog(@"%@", error);
        return cleanup();
    }
    
    
    NSData *result = CFBridgingRelease(SecTransformExecute(group, &error));
    if (error) {
        NSLog(@"RSA signature verification failed: %@", error);
        return cleanup();
    }
    
    cleanup();
    return result;
}

@end
