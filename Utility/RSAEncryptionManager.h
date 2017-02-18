//
//  RSAEncryptionManager.h
//  LogDecryptor
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSAEncryptionManager : NSObject

- (instancetype)initWithPublicKeyData:(NSData *)data;
- (instancetype)initWithPrivateKeyData:(NSData *)data;
- (NSData*)encryptData:(NSData*) data;
- (NSData*)decryptData:(NSData*) data;

@end
