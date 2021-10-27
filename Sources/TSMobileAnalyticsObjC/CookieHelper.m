//
//  CookieHelper.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-09.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "CookieHelper.h"

@implementation CookieHelper

+ (void)setCookieWithValue:(NSString *)value forKey:(NSString *)key andDomain:(NSString *)domain {

    NSDictionary *properties = [self cookiePropertiesWithDomain:domain key:key value:value];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookie:cookie];
    
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStorage = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];
        [cookieStorage setCookie:cookie completionHandler:^{
        }];
    }
}

+ (void)setCookieWithBoolValue:(BOOL)value forKey:(NSString *)key andDomain:(NSString *)domain {
    [self setCookieWithValue:(value ? @"true" : @"false")
                      forKey:key
                   andDomain:domain];
}

+ (void)deleteCookiesForDomains:(NSArray <NSString *> *)domains
                     completion:(void (^)(void))completion {
    if (domains == nil || domains.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        for (NSString *domain in domains) {
            if ([[cookie domain] rangeOfString:domain].location != NSNotFound) {
                [storage deleteCookie:cookie];
                break;
            }
        }
    }
    
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *wkStorage = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];
        [wkStorage getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
            if (cookies.count > 0) {
                NSMutableArray <NSHTTPCookie *> *cookiesToDelete = [NSMutableArray new];
                for (NSHTTPCookie *cookie in cookies) {
                    for (NSString *domain in domains) {
                        if ([[cookie domain] rangeOfString:domain].location != NSNotFound) {
                            [cookiesToDelete addObject:cookie];
                            break;
                        }
                    }
                }
                
                __block int deletedCount = 0;
                if (cookiesToDelete.count > 0) {
                    for (NSHTTPCookie *cookie in cookiesToDelete) {
                        [wkStorage deleteCookie:cookie completionHandler:^{
                            deletedCount++;
                            if (deletedCount == cookiesToDelete.count && completion) {
                                completion();
                            }
                        }];
                    }
                } else if (completion) {
                    completion();
                }
            } else if(completion) {
                completion();
            }
        }];
    } else if(completion) {
        completion();
    }
}

+ (NSDictionary *)cookiePropertiesWithDomain:(NSString *)domain
                                         key:(NSString *)key
                                       value:(NSString *)value {
    return @{
        NSHTTPCookieDomain: domain,
        NSHTTPCookieName: key,
        NSHTTPCookiePath: @"/",
        NSHTTPCookieValue: value
    };
}

@end
