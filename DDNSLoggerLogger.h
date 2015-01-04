//
//  DDNSLoggerLogger.h
//  Created by Peter Steinberger on 26.10.10.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

extern NSString * const DDNSLoggerOptionBonjourServiceName; // NSString, not defined by default

// If a TTY logger is attached to CocoaLumberjack, set this option to NO to avoid NSLogger to capture messages sent to itself.
extern NSString * const DDNSLoggerOptionCaptureSystemConsole; // Boolean NSNumber, YES by default

@interface DDNSLoggerLogger : DDAbstractLogger <DDLogger>

@property (nonatomic, readonly) BOOL running;

+ (DDNSLoggerLogger *)sharedInstance;

/// should setup before `- (void)start`
- (void)setupWithOptions:(NSDictionary *)options;

- (void)start;
- (void)stop;

@end
