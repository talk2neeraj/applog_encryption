//
//  LogManager.m
//  ILOGFoundation
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import "LogManager.h"
#import "LogServiceProvider.h"
#import "LogServiceReceiver.h"

@interface LogManager () <LogServiceReceiver>

@property (readonly) NSXPCConnection *connection;
@property (nonatomic, readonly) dispatch_queue_t queue;


@end

@implementation LogManager

+ (LogManager *)sharedLogManager
{
    static LogManager* logManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        logManager = [[LogManager alloc] init];
    });
    
    return logManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("com.nik.log.logging", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void) logMessage:(NSString *)message forLogLevel:(int) logLevel
{
    [self performRemoteBlock:^(id<LogServiceProvider> logServiceProvider) {
        [logServiceProvider logMessage: message forLogLevel: logLevel];
    }];
}

- (void)setUpNewLogFile
{
    [self performRemoteBlock:^(id<LogServiceProvider> logServiceProvider) {
        [logServiceProvider setUpNewLogFile];
    }];
}


- (void)performRemoteBlock:(void(^)(id <LogServiceProvider>))block
{
    NSParameterAssert(block);
    
    // Tasks in serial queues execute one at a time, each task starting only after the preceding task has finished.
    dispatch_async(_queue, ^
    {
        if (!_connection)
        {
            [self setupConnectionLocked];
        }
        block(_connection.remoteObjectProxy);
    });
}

- (void)setupConnectionLocked
{
    NSXPCConnection *connection = [[NSXPCConnection alloc] initWithServiceName:@"com.nik.logservice"];
    
    // The service will implement the 'ILOGScreenSharingService' protocol.
    NSXPCInterface *remote = [NSXPCInterface interfaceWithProtocol:@protocol(LogServiceProvider)];
    connection.remoteObjectInterface = remote;
    
    // We implement the 'ILOGILOGScreenSharingServiceReceiver' protocol, so the service can report progress back.
    NSXPCInterface *local = [NSXPCInterface interfaceWithProtocol:@protocol(LogServiceReceiver)];
    connection.exportedInterface = local;
    connection.exportedObject = self;
    
    [connection resume];
    
    _connection = connection;
}
@end
