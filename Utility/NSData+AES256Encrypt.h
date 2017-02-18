//
//  NSData+AES256Encrypt.h
//  ILOGFoundation
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256Encrypt)

- (NSData*)aes256EncryptWithKey:(NSString*)key;
- (NSData*)aes256DecryptWithKey:(NSString*)key;

@end
