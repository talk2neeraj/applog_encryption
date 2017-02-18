//
//  LogService.m
//  LogService
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import "LogService.h"
#import "LogServiceProvider.h"
#import "LogServiceReceiver.h"
#import "NSData+AES256Encrypt.h"
#import "NSData+RSAEncrypt.h"
#import "NSString+CommandExecution.h"

NSString * const kLogFileExtn = @"aelf";


@interface LogService ()

@property (strong) NSXPCConnection *connection;
@property (copy) NSString* encryptionKey;
@property (strong) NSOutputStream* outputStream;
@property (strong) NSData *linebreakData;
@property (strong) NSArray *logLevelStrings;
@property (assign) NSUInteger logLevelCount;

@property (copy) NSString* executableName;
@property (copy) NSString* logFileName;
@property (copy) NSString* archivedLogFileName;
@end

@implementation LogService

+ (LogService *)sharedLogService
{
    static LogService* logService = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logService = [[LogService alloc] init];
    });
    
    return logService;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.logLevelStrings = @[@"<emerg>", @"<alert>", @"<critical>", @"<error>", @"<warning>", @"<notice>", @"<info>", @"<debug>"];
        self.logLevelCount = [self.logLevelStrings count];
        
        self.linebreakData = [@"\r\n\r\n" dataUsingEncoding: NSUTF8StringEncoding];
        
        self.executableName = [[NSURL fileURLWithPath: [[NSBundle mainBundle] executablePath]] lastPathComponent];
        self.archivedLogFileName = [self.executableName stringByAppendingString:@"-"];
        self.logFileName = [self.executableName stringByAppendingPathExtension:kLogFileExtn];

        [self generateRandomEncryptionKey];
        [self setUpNewLogFile];
    }
    return self;
}

- (void)dealloc
{
    [self.outputStream close];
    self.outputStream = nil;
}

-(void) generateRandomEncryptionKey
{
    self.encryptionKey = [@"openssl rand -base64 16" runAsCommand];
    if(self.encryptionKey == nil)
    {
        self.encryptionKey = @"XYZ-ABC-PQRS";
    }
}

- (NSURL *)logsDirectoryURL
{
    NSURL *libraryDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    
    NSString *path = [[NSString pathWithComponents:@[@"Logs", self.executableName]] stringByStandardizingPath];
    NSURL *logsDirectoryURL = [libraryDirectoryURL URLByAppendingPathComponent:path isDirectory:YES];
    
    (void) [[NSFileManager defaultManager] createDirectoryAtURL:logsDirectoryURL withIntermediateDirectories:YES attributes:nil error:NULL];
    
    return logsDirectoryURL;
}

- (BOOL) shouldDeleteOldLogFiles: (NSDate *)logFileCreationDate
{
    NSDate *date7daysBefore = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
    if ([date7daysBefore compare:logFileCreationDate] == NSOrderedDescending || [date7daysBefore compare:logFileCreationDate] == NSOrderedSame){
        return YES;
    }else{
        return NO;
    }
}

- (NSURL *)renameURLWithResources:(NSDictionary *)resources inLogsDirectoryURL:(NSURL *)logsDirectoryURLArg
{
    NSDate *fileCreationDate = resources[NSURLCreationDateKey];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *fileCreationDateString = [dateFormatter stringFromDate:fileCreationDate];
    if (fileCreationDateString == nil)
    {
        fileCreationDateString = [dateFormatter stringFromDate:[NSDate date]];
        if (fileCreationDateString == nil)
        {
            fileCreationDateString = [[NSDate date] description];
        }
    }
    
    NSURL *destURL = [logsDirectoryURLArg URLByAppendingPathComponent:[[self.archivedLogFileName stringByAppendingString:fileCreationDateString] stringByAppendingPathExtension: kLogFileExtn]];
    
    return destURL;
}


- (void)setUpNewLogFile
{
    [self.outputStream close];
    self.outputStream = nil;
    
    NSURL *logsDirectoryURL = [self logsDirectoryURL];
    
    NSDirectoryEnumerationOptions options = (NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles);
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:logsDirectoryURL includingPropertiesForKeys:@[NSURLCreationDateKey] options:options error:NULL];
    
    NSIndexSet *logFileIndexes = [directoryContents indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                  {
                                      return [[obj pathExtension] isEqualToString: kLogFileExtn];
                                  }];
    
    NSArray *logFiles = [directoryContents objectsAtIndexes:logFileIndexes];
    
    //    Deleting logs files older than a week and exactly a week.
    for (id logFile in logFiles)
    {
        NSDate *logFileCreationDate = [logFile resourceValuesForKeys:@[NSURLCreationDateKey] error:NULL][NSURLCreationDateKey];
        BOOL shouldDelete = [self shouldDeleteOldLogFiles:logFileCreationDate];
        if (shouldDelete)
        {
            [[NSFileManager defaultManager] removeItemAtURL:logFile error:NULL];
        }
    }
    
    NSURL *sourceURL = [logsDirectoryURL URLByAppendingPathComponent:self.logFileName];
    
    if ([sourceURL checkResourceIsReachableAndReturnError:NULL] == NO)
    {
        (void) [[NSData data] writeToURL:sourceURL options:0 error:NULL];
    }
    else
    {
        NSDictionary *resources = [sourceURL resourceValuesForKeys:@[NSURLCreationDateKey] error:NULL];
        
        NSURL *destURL = [self renameURLWithResources:resources inLogsDirectoryURL:logsDirectoryURL];
        
        if ([[NSFileManager defaultManager] moveItemAtURL:sourceURL toURL:destURL error:NULL])
        {
            (void) [[NSData data] writeToURL:sourceURL options:0 error:NULL];
        }
    }
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath: [sourceURL path] append: YES];
    [self.outputStream open];
    
    NSData *keyData = [[self.encryptionKey dataUsingEncoding: NSUTF8StringEncoding] encryptWithRSA];
    [self writeData: keyData];
}

#pragma mark - NSXPCListenerDelegate protocol conformance

- (BOOL)listener:(NSXPCListener *__unused)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // Configure the new connection and resume it. Because this is a singleton object, we set 'self' as the exported object and configure the connection to export the 'ScreenSharingService' protocol that we implement on this object.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(LogServiceProvider)];
    newConnection.exportedObject = self;
    
    // We'll take advantage of the bi-directional nature of NSXPCConnections to send progress back to the caller.
    // The remote object implements the 'ScreenSharingServiceReceiver' protocol, so the service can report progress back.
    NSXPCInterface *remote = [NSXPCInterface interfaceWithProtocol:@protocol(LogServiceReceiver)];
    newConnection.remoteObjectInterface = remote;
    
    self.connection = newConnection;
    
    __weak typeof(self) weakSelf = self;
    newConnection.invalidationHandler = ^
    {
        typeof(self) strongSelf = weakSelf;
        strongSelf.connection = nil;
    };
    
    [newConnection resume];
    xpc_transaction_begin();
    
    return YES;
}

#pragma --mark LogServiceProvider

-(void) writeData:(NSData*) data
{
    if(data.length)
    {
        [self.outputStream write: [data bytes] maxLength: [data length]];
        [self.outputStream write: [self.linebreakData bytes] maxLength: [self.linebreakData length]];
    }
}


-(void) logMessage:(NSString *)message forLogLevel:(int) logLevel
{
    logLevel = logLevel % self.logLevelCount;
    NSString *leveStr = self.logLevelStrings[logLevel];
    
    NSString *logString = [NSString stringWithFormat: @"%@ %@: %@", [NSDate date], leveStr, message];
    NSData* data = [logString dataUsingEncoding: NSUTF8StringEncoding];
    data = [data aes256EncryptWithKey: self.encryptionKey];
    [self writeData: data];
}


@end
