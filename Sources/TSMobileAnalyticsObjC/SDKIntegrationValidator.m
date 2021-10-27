//
//  SDKIntegrationValidator.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-13.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import "SDKIntegrationValidator.h"
#import "Logger.h"
#import "TSMobileAnalyticsConstants.h"
#import "NSBundle+Sifo.h"

@implementation SDKIntegrationValidator

+ (void)validateWithIdfa:(BOOL)idfa
         applicationName:(NSString *)applicationName
                    cpid:(NSString *)cpid {
    if (applicationName == nil) {
        [Logger logError:@[
            @"Application name must not be nil."
        ]];
    }
    else if ([applicationName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length == 0) {
        [Logger logError:@[
            @"Application name must not empty string."
        ]];
    }
    
    if (cpid == nil) {
        [Logger logError:@[
            @"CPID must not be nil."
        ]];
    }
    else if ([cpid stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length == 0) {
        [Logger logError:@[
            @"CPID must not be empty string."
        ]];
    }
    else if (cpid.length != cpidMaxLengthCodigo) {
        [Logger logError:@[
            [NSString stringWithFormat:@"CPID incorrect length, should be %i characters.", cpidMaxLengthCodigo]
        ]];
    }
    
    if (![NSBundle.mainBundle hasAppExchangeURLSchemeSetup]) {
        [Logger logError:@[
            @"Exchange url scheme not setup!",
            [NSString stringWithFormat:@"Add %@ as url scheme.", [NSBundle.mainBundle appExchangeScheme]],
            @"",
            @"Add to your info.plist:",
            @"<key>CFBundleURLTypes</key>",
            @"<array>",
            @"    <dict>",
            @"        <key>CFBundleTypeRole</key>",
            @"        <string>None</string>",
            @"        <key>CFBundleURLSchemes</key>",
            @"        <array>",
            [NSString stringWithFormat:@"            <string>%@</string>", [NSBundle.mainBundle appExchangeScheme]],
            @"        </array>",
            @"    </dict>",
            @"</array>"
        ]];
    }
    
    if (![NSBundle.mainBundle hasAppQuerySchemeSetup]) {
        [Logger logError:@[
            @"Panelist app query scheme not setup!",
            [NSString stringWithFormat:@"Add %@ as query scheme.", kInternetApplicationScheme],
            @"",
            @"Modify to your info.plist to contain:",
            @"<key>LSApplicationQueriesSchemes</key>",
            @"<array>",
            [NSString stringWithFormat:@"    <string>%@</string>", kInternetApplicationScheme],
            @"</array>"
        ]];
    }
}

@end
