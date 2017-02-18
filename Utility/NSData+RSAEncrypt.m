//
//  NSData+RSAEncrypt.m
//  LogDecryptor
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import "NSData+RSAEncrypt.h"
#import "RSAEncryptionManager.h"

@implementation NSData (RSAEncrypt)

- (NSData*)encryptWithRSA
{
    static RSAEncryptionManager *encryptionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSData *keyData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"id_rsa" ofType:@"pem"]];
        encryptionManager = [[RSAEncryptionManager alloc] initWithPublicKeyData: keyData];
    });
    return [encryptionManager encryptData: self];
}

- (NSData*)decryptWithRSA
{
    static RSAEncryptionManager *decryptionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSData *keyData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"id_rsa" ofType:@""]];
        decryptionManager = [[RSAEncryptionManager alloc] initWithPrivateKeyData: keyData];
        
    });
    
    return [decryptionManager decryptData: self];
    
}

@end
