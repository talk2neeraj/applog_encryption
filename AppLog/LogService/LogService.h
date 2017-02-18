//
//  LogService.h
//  LogService
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogServiceProvider.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface LogService : NSObject <LogServiceProvider, NSXPCListenerDelegate>

+ (LogService *)sharedLogService;

@end
