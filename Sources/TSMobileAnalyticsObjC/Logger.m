//
//  Logger.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-29.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import "Logger.h"

static BOOL errors = true;
static BOOL warnings = false;
static BOOL info = false;

@implementation Logger

#ifdef NDEBUG
#  define TSLog(...)
#else
#  define TSLog NSLog
#endif

+ (void)printErrors:(BOOL)print {
    errors = print;
}

+ (void)printWarnings:(BOOL)print {
    warnings = print;
}

+ (void)printInfo:(BOOL)print {
    info = print;
}

+ (void)logError:(NSArray <NSString *> *)messages {
    if (errors) {
        [self printMessages:messages type:@"Error"];
    }
}

+ (void)logWarning:(NSArray <NSString *> *)messages {
    if (warnings) {
        [self printMessages:messages type:@"Warning"];
    }
}

+ (void)logInfo:(NSArray <NSString *> *)messages {
    if (info) {
        [self printMessages:messages type:@"Info"];
    }
}

+ (void)printMessages:(NSArray <NSString *> *)messages
                 type:(NSString *)type {
    NSMutableString *warning = [NSMutableString string];
    [warning appendString:@"\n"];
    [warning appendString:@"+----------------\n"];
    [warning appendFormat:@"| TNS Sifo SDK - %@:\n", type];
    for (NSString *m in messages) {
        [warning appendFormat:@"| %@\n", m];
    }
    [warning appendString:@"+----------------\n"];
    TSLog(@"%@", warning);
}

@end
