//
//  WKWebView+Sifo.h
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-09.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#ifndef WKWebView_Sifo_h
#define WKWebView_Sifo_h

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView(sifo)

- (void)setLocalStorageWithCookies:(NSArray <NSDictionary <NSString *, id> *> *)cookies;

@end

#endif /* WKWebView_Sifo_h */
