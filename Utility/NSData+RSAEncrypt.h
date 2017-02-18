//
//  NSData+RSAEncrypt.h
//  LogDecryptor
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (RSAEncrypt)

- (NSData*)encryptWithRSA;
- (NSData*)decryptWithRSA;

@end
