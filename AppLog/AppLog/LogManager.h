//
//  LogManager.h
//  ILOGFoundation
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogManager : NSObject

+ (LogManager *)sharedLogManager;

-(void) logMessage:(NSString *)message forLogLevel:(int) logLevel;
- (void)setUpNewLogFile;

@end
