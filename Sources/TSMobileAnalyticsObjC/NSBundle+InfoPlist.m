//
//  NSBundle+InfoPlist.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-13.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import "NSBundle+InfoPlist.h"

@implementation NSBundle (infoPlist)

- (BOOL)containsURLScheme:(NSString *)scheme {
    NSArray *bundleURLTypes = [self objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (bundleURLTypes != nil && [bundleURLTypes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *bundleURLType in bundleURLTypes) {
            if ([bundleURLType isKindOfClass:[NSDictionary class]]) {
                NSArray *urlSchemes = bundleURLType[@"CFBundleURLSchemes"];
                if(urlSchemes != nil && [urlSchemes isKindOfClass:[NSArray class]]) {
                    for (NSString *urlScheme in urlSchemes) {
                        if ([urlScheme isKindOfClass:[NSString class]] && [urlScheme.lowercaseString isEqual:scheme.lowercaseString]) {
                            return true;
                        }
                    }
                }
            }
        }
    }
    return false;
}

- (BOOL)containsQueryScheme:(NSString *)scheme {
    NSArray *querySchemes = [self objectForInfoDictionaryKey:@"LSApplicationQueriesSchemes"];
    if (querySchemes != nil && [querySchemes isKindOfClass:[NSArray class]]) {
        for (NSString *queryScheme in querySchemes) {
            if ([queryScheme isKindOfClass:[NSString class]] && [queryScheme.lowercaseString isEqual:scheme.lowercaseString]) {
                return true;
            }
        }
    }
    return false;
}

@end
