//
//  DDLoggerWrapper.m
//  
//
//  Created by Antonino Urbano on 2015-07-14.
//
//

#import <Foundation/Foundation.h>
#import "DDLoggerWrapper.h"

// Logging Framework Lumberjack
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

// Definition of the current log level
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@implementation DDLoggerWrapper

+ (void) logVerbose:(NSString *)message {
    DDLogVerbose(message);
}

+ (void) logError:(NSString *)message {
    DDLogError(message);
}

+ (void) logInfo:(NSString *)message {
    DDLogInfo(message);
}

@end
