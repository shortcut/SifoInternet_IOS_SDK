//
//  WKWebView+LocalStorage.h
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-08.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#ifndef WKWebView_LocalStorage_h
#define WKWebView_LocalStorage_h

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView(localStorage)

- (void)setLocalStorage:(NSDictionary<NSString *, NSString *> *)localStorage
             completion:(void (^)(NSError *error))completion;

@end

#endif /* WKWebView_LocalStorage_h */
