//
//  NSBundle+InfoPlist.h
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-13.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#ifndef NSBundle_InfoPlist_h
#define NSBundle_InfoPlist_h

#import <Foundation/Foundation.h>

@interface NSBundle(infoPlist)

- (BOOL)containsURLScheme:(NSString *)scheme;
- (BOOL)containsQueryScheme:(NSString *)scheme;

@end

#endif /* NSBundle_InfoPlist_h */
