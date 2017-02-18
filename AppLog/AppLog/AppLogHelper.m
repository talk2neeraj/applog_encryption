//
//  AppLogHelper.m
//  AppLog
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import "AppLogHelper.h"
#import <asl.h>
#import "LogManager.h"

void _errorLog( NSString *format, ...)
{
    va_list ap;
    va_start(ap, format);
    va_end(ap);
    NSString *logMessage = [[NSString alloc] initWithFormat: format arguments:ap];
    [[LogManager sharedLogManager] logMessage:logMessage  forLogLevel:ASL_LEVEL_ERR];
}

void _warningLog(NSString *format, ...)
{
    va_list ap;
    va_start(ap, format);
    va_end(ap);
    NSString *logMessage = [[NSString alloc] initWithFormat: format arguments:ap];
    [[LogManager sharedLogManager] logMessage:logMessage  forLogLevel:ASL_LEVEL_WARNING];
}



void _infoLog(NSString *format, ...)
{
    va_list ap;
    va_start(ap, format);
    va_end(ap);
    NSString *logMessage = [[NSString alloc] initWithFormat: format arguments:ap];
    [[LogManager sharedLogManager] logMessage:logMessage  forLogLevel:ASL_LEVEL_INFO];
}

void _debugLog(NSString *format, ...)
{
    va_list ap;
    va_start(ap, format);
    va_end(ap);
    NSString *logMessage = [[NSString alloc] initWithFormat: format arguments:ap];
    [[LogManager sharedLogManager] logMessage:logMessage  forLogLevel:ASL_LEVEL_DEBUG];
}