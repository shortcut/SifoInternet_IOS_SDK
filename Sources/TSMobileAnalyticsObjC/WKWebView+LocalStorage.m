//
//  WKWebView+LocalStorage.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-08.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import "WKWebView+LocalStorage.h"

@implementation WKWebView(localStorage)

- (void)setLocalStorage:(NSDictionary<NSString *, NSString *> *)localStorage
             completion:(void (^)(NSError *error))completion {
    NSString *javascript = @"";
    for (NSString *key in localStorage.allKeys) {
        javascript = [javascript stringByAppendingFormat:@"localStorage.setItem(\"%@\", \"%@\");", key, localStorage[key]];
    }
    [self evaluate:javascript
        completion:completion];
}

- (void)evaluate:(NSString *)javascript
      completion:(void (^)(NSError *error))completion {
    [self evaluate:javascript
        retryCount:0
          retryMax:60
        completion:completion];
}

- (void)evaluate:(NSString *)javascript
      retryCount:(int)retryCount
        retryMax:(int)retryMax
      completion:(void (^)(NSError *error))completion {
    [self evaluateJavaScript:javascript
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error.userInfo[@"WKJavaScriptExceptionMessage"] != nil) {
            if (retryCount < retryMax) {
                typeof(self) __weak weakSelf = self;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    typeof(weakSelf) strongSelf = weakSelf;

                    if (strongSelf != nil) {
                        [strongSelf evaluate:javascript
                                  retryCount:retryCount + 1
                                    retryMax:retryMax
                                  completion:completion];
                    } else {
                        if (completion != nil) {
                            completion(nil);
                        }
                    }
                });
            } else {
                if (completion != nil) {
                    completion(error);
                }
            }
        } else if (error != nil) {
            if (completion != nil) {
                completion(error);
            }
        } else {
            if (completion != nil) {
                completion(nil);
            }
        }
    }];
}

@end
