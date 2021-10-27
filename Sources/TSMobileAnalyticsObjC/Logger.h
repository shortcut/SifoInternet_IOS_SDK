//
//  Logger.h
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-29.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Logger_h
#define Logger_h

@interface Logger : NSObject

+ (void)printErrors:(BOOL)print;
+ (void)printWarnings:(BOOL)print;
+ (void)printInfo:(BOOL)print;

+ (void)logError:(NSArray <NSString *> *)messages;
+ (void)logWarning:(NSArray <NSString *> *)messages;
+ (void)logInfo:(NSArray <NSString *> *)messages;

@end

#endif /* Logger_h */
