//
//  DDLoggerWrapper.h
//  
//
//  Created by Antonino Urbano on 2015-07-14.
//
//

#import <Foundation/Foundation.h>

@interface DDLoggerWrapper : NSObject
+ (void) logVerbose:(NSString *)message;
+ (void) logError:(NSString *)message;
+ (void) logInfo:(NSString *)message;
@end
