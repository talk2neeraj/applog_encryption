//
//  AppDelegate.m
//  LogDecryptor
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+AES256Encrypt.h"
#import "RSAEncryptionManager.h"
#import "NSData+RSAEncrypt.h"
#import "NSString+CommandExecution.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (copy) NSString* encryptionKey;
@property (strong) NSData *linebreakData;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.linebreakData = [@"\r\n\r\n" dataUsingEncoding: NSUTF8StringEncoding];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    NSData * fileData = [NSData dataWithContentsOfFile: filename];
    self.textView.string = [self decryptLog: fileData];
    [self.window makeKeyAndOrderFront: self];
    
    return YES;
}


-(NSString *) decryptLog:(NSData *) data
{
    if(!data) return nil;

    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream open];
    
    NSData *delimiterData = self.linebreakData;
    NSUInteger startLocation = 0;
    BOOL keyFound = NO;
    for(;;)
    {
        NSRange delimiterDataRange = [data rangeOfData: delimiterData options:0 range: NSMakeRange(startLocation, [data length] - startLocation)];
        if(delimiterDataRange.location == NSNotFound)
        {
            break;
        }
        
        NSRange subDataRange = NSMakeRange(startLocation, delimiterDataRange.location - startLocation);
        
        startLocation = NSMaxRange(subDataRange) + delimiterDataRange.length;
        
        if(subDataRange.length > 0)
        {
            NSData *subData = [data subdataWithRange:subDataRange];
            if(keyFound == NO)
            {
                NSData* decryptedKey = [subData decryptWithRSA];
                NSString *usedEncryptionKey = [[NSString alloc] initWithData: decryptedKey encoding:NSUTF8StringEncoding];
                if(usedEncryptionKey)
                {
                    self.encryptionKey = usedEncryptionKey;
                    keyFound = YES;
                }
            }
            else
            {
                subData = [subData aes256DecryptWithKey: self.encryptionKey];
                [outputStream write: [subData bytes] maxLength: [subData length]];
                [outputStream write: [self.linebreakData bytes] maxLength: [self.linebreakData length]];
            }
        }
    }
    
    NSData *contents = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    [outputStream close];
    
    NSString *logMessage = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
    return logMessage;
}

@end
