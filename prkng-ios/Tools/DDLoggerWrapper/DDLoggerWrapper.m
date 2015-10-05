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
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
static const int ddLogLevel = LOG_LEVEL_INFO;
//static const int ddLogLevel = LOG_LEVEL_WARNING;
//static const int ddLogLevel = LOG_LEVEL_ERROR;

@implementation DDLoggerWrapper

+ (void) logVerbose:(NSString *)message {
    DDLogVerbose(message);
}

+ (void) logWarning:(NSString *)message {
    DDLogWarn(message);
}

+ (void) logError:(NSString *)message {
    DDLogError(message);
}

+ (void) logInfo:(NSString *)message {
    DDLogInfo(message);
}

@end
