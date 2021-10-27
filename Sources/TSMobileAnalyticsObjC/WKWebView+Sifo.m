//
//  WKWebView+Sifo.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-09.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import "WKWebView+Sifo.h"
#import "WKWebView+LocalStorage.h"

@implementation WKWebView (sifo)

- (void)setLocalStorageWithCookies:(NSArray <NSDictionary <NSString *, id> *> *)cookies {
    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    if (cookies) {
        for (NSDictionary *cookie in cookies) {
            if (cookie[@"value"] != nil && cookie[@"key"] != nil && cookie[@"domain"] != nil) {
                NSString *key = [NSString stringWithFormat:@"%@^%@", cookie[@"key"], cookie[@"domain"]];
                NSString *value = [NSString stringWithFormat:@"%@", cookie[@"value"]];
                
                keyValues[key] = value;
            }
        }
    }
    [self setLocalStorage:keyValues completion:nil];
}

@end
