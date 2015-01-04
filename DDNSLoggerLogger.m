//
//  DDNSLoggerLogger.m
//  Created by Peter Steinberger on 26.10.10.
//

#import "DDNSLoggerLogger.h"

// NSLogger is needed: http://github.com/fpillet/NSLogger
#import "LoggerClient.h"

NSString * const DDNSLoggerOptionBonjourServiceName = @"bonjourServiceName";
NSString * const DDNSLoggerOptionCaptureSystemConsole = @"captureSystemConsole";

@interface DDNSLoggerLogger ()

@property (nonatomic, assign) BOOL running;

@end

@implementation DDNSLoggerLogger

static DDNSLoggerLogger *sharedInstance;

+ (DDNSLoggerLogger *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DDNSLoggerLogger alloc] init];
    });
    return sharedInstance;
}

- (void)start {
    if (self.running) {
        return;
    }
    LoggerStart(NULL);
    self.running = YES;
}

- (void)stop {
    if (!self.running) {
        return;
    }
    LoggerStop(NULL);
    self.running = NO;
}

- (void)setupWithOptions:(NSDictionary *)options {
    BOOL running = self.running;
    [self stop];
	
	NSString *bonjourServiceName = options[DDNSLoggerOptionBonjourServiceName];
	BOOL captureSystemConsole = YES;
	if (options[DDNSLoggerOptionCaptureSystemConsole] != nil) {
		captureSystemConsole = [options[DDNSLoggerOptionCaptureSystemConsole] boolValue];
	}
	
	uint32_t loggerOptions = LOGGER_DEFAULT_OPTIONS;
	if (!captureSystemConsole) {
		loggerOptions &= (uint32_t)~kLoggerOption_CaptureSystemConsole;
	}
	
    LoggerSetupBonjour(NULL, NULL, (__bridge CFStringRef)bonjourServiceName);
	LoggerSetOptions(NULL, loggerOptions);
	
	if (running) {
        [self start];
    }
}

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *logMsg = logMessage.message;

    if (_logFormatter) {
        // formatting is supported but not encouraged!
        logMsg = [_logFormatter formatLogMessage:logMessage];
    }

    if (logMsg) {
        int nsloggerLogLevel;
        switch (logMessage->_flag) {
                // NSLogger log levels start a 0, the bigger the number,
                // the more specific / detailed the trace is meant to be
            case DDLogFlagError: nsloggerLogLevel = 0; break;
            case DDLogFlagWarning: nsloggerLogLevel  = 1; break;
            case DDLogFlagInfo: nsloggerLogLevel  = 2; break;
            default: nsloggerLogLevel             = 3; break;
        }

        LogMessageF([logMessage->_file UTF8String], (int)logMessage->_line, [logMessage->_function UTF8String], logMessage->_fileName,
                    nsloggerLogLevel, @"%@", logMsg);
    }
}

- (NSString *)loggerName {
    return @"cocoa.lumberjack.NSLogger";
}

@end
