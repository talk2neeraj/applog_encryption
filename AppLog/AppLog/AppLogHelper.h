//
//  AppLogHelper.h
//  AppLog
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Local Logging Macros

#define APP_LOG_INFO(format, ...) _infoLog(@"%s:%ld %s", __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])

#define APP_LOG_ERR(format,...) _errorLog(@"%s:%ld %s", __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])

#define APP_LOG_WARNING(format,...) _warningLog(@"%s:%ld %s", __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])

#define APP_LOG_DEBUG(format,...) _debugLog(@"%s:%ld %s", __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])


void _errorLog(NSString *format, ...);
void _warningLog(NSString *format, ...);
void _infoLog(NSString *format, ...);
void _debugLog(NSString *format, ...);

