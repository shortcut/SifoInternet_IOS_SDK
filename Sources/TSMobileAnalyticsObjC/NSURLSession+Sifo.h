//
//  NSURLSession+Sifo.h
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-27.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NSURLSession_Sifo_h
#define NSURLSession_Sifo_h

@interface NSURLSession (sifo)

- (void)sendTagWithSdkVersion:(NSString *)sdkVersion
                   categories:(NSArray <NSString *> *)categories
                    contentId:(NSString *)contentId
                    reference:(NSString *)reference
                         cpid:(NSString *)cpid
                         euid:(NSString *)euid
            trackPanelistOnly:(BOOL)trackPanelistOnly
               isWebViewBased:(BOOL)isWebViewBased
                   completion:(void (^)(BOOL success, NSError *error))completionBlock;

- (void)syncWithSdkVersion:(NSString *)sdkVersion
                   appName:(NSString *)appName
                  syncJson:(NSString *)syncJson
                completion:(void (^)(NSString *cookieKey, NSError *error))completionBlock;

@end

#endif /* NSURLSession_Sifo_h */
