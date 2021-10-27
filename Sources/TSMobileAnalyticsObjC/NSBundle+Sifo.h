//
//  NSBundle+Sifo.h
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-13.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#ifndef NSBundle_Sifo_h
#define NSBundle_Sifo_h

#import <Foundation/Foundation.h>

@interface NSBundle (sifo)

- (NSString *)appExchangeScheme;

- (BOOL)hasAppExchangeURLSchemeSetup;
- (BOOL)hasAppQuerySchemeSetup;
+ (NSString *)appVersionString;

@end

#endif /* NSBundle_Sifo_h */
