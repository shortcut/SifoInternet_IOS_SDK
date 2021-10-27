//
//  CookieHelper.h
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-09.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#ifndef CookieHelper_h
#define CookieHelper_h

#import <Foundation/Foundation.h>

@interface CookieHelper : NSObject

+ (void)setCookieWithValue:(NSString *)value
                    forKey:(NSString *)key
                 andDomain:(NSString *)domain;

+ (void)setCookieWithBoolValue:(BOOL)value
                        forKey:(NSString *)key
                     andDomain:(NSString *)domain;

+ (void)deleteCookiesForDomains:(NSArray <NSString *> *)domains
                     completion:(void (^)(void))completion;

@end

#endif /* CookieHelper_h */
