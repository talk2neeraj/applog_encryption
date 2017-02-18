//
//  main.m
//  LogService
//
//  Created by Neeraj Singh on 5/21/16.
//  Copyright © 2016 Nik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogService.h"

int main(int argc, const char *argv[])
{
    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = [LogService sharedLogService];
    
    // Resuming the serviceListener starts this service. This method does not return.
    [listener resume];
    return 0;
}
