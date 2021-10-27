#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CookieHelper.h"
#import "Logger.h"
#import "TSMobileAnalytics.h"
#import "TSMobileAnalyticsConstants.h"
#import "SDKIntegrationValidator.h"
#import "KeychainItemWrapper.h"
#import "WKWebView+Sifo.h"
#import "NSBundle+Sifo.h"
#import "NSURLSession+Sifo.h"
#import "NSString+Encoding.h"

// Fix this!
//
//static NSString *versionString = @CURRENT_PROJECT_VERSION;
static NSString *versionString = @"5.3.0";
static TSMobileAnalytics *frameworkInstance = nil;
static NSMutableArray <WKWebView *> *webviews = nil;

@interface TSMobileAnalytics ()

@property (nonatomic, strong) NSString *cpid;
@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) NSString *mref;
@property (nonatomic, strong) NSString *mEuid;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *additionals;
@property (nonatomic, strong) KeychainItemWrapper *keychainItemWrapper;
@property (nonatomic) TrackingType trackingType;
@property (nonatomic) BOOL isWebViewBased;
@property (nonatomic) BOOL trackSystemIdentifiers;
@property (nonatomic) BOOL syncWithBackendFirst;
@property (nonatomic) BOOL useJsonUrlSchemeSyncFormat;

@end

@implementation TSMobileAnalytics

#pragma mark - Lifecycle

+ (void)initializeWithCPID:(NSString *)cpid
           applicationName:(NSString *)appName
              trackingType:(TrackingType)trackingType
enableSystemIdentifierTracking:(BOOL)enableSystemIdentifierTracking
            isWebViewBased:(BOOL)webViewBased
       keychainAccessGroup:(NSString *)keychainAccessGroup
               additionals:(NSDictionary <NSString *, NSString *> *)additionals {
    if (frameworkInstance == nil || [additionals[secretOptionForceReinitialize] isEqualToString:@"true"]) {
        
        if (webviews == nil) {
            webviews = [NSMutableArray new];
        }
        
        frameworkInstance = [[TSMobileAnalytics alloc] initWithCPID:cpid
                                                            appName:appName
                                                       trackingType:trackingType
                                     enableSystemIdentifierTracking:enableSystemIdentifierTracking
                                                     isWebViewBased:webViewBased
                                                keychainAccessGroup:keychainAccessGroup
                                                        additionals:additionals];
    } else {
        [Logger logWarning:@[@"Framework has already been initiated."]];
    }
}

+ (void)initializeWithCPID:(NSString *)cpid
           applicationName:(NSString *)appName
              trackingType:(TrackingType)trackingType
enableSystemIdentifierTracking:(BOOL)enableSystemIdentifierTracking
            isWebViewBased:(BOOL)webViewBased
       keychainAccessGroup:(NSString *)keychainAccessGroup {
    [TSMobileAnalytics initializeWithCPID:cpid
                          applicationName:appName
                             trackingType:trackingType
           enableSystemIdentifierTracking:enableSystemIdentifierTracking
                           isWebViewBased:webViewBased
                      keychainAccessGroup:keychainAccessGroup
                              additionals:nil];
}

+ (void)initializeWithCPID:(NSString *)cpid
           applicationName:(NSString *)appName
              trackingType:(TrackingType)trackingType
enableSystemIdentifierTracking:(BOOL)enableSystemIdentifierTracking
       keychainAccessGroup:(NSString *)keychainAccessGroup {
    [TSMobileAnalytics initializeWithCPID:cpid
                          applicationName:appName
                             trackingType:trackingType
           enableSystemIdentifierTracking:enableSystemIdentifierTracking
                           isWebViewBased:false
                      keychainAccessGroup:keychainAccessGroup
                              additionals:nil];
}

- (id)initWithCPID:(NSString *)cpid
           appName:(NSString *)appName
      trackingType:(TrackingType)trackingType
enableSystemIdentifierTracking:(BOOL)enableSystemIdentifierTracking
    isWebViewBased:(BOOL)webViewBased
keychainAccessGroup:(NSString *)accessGroup
       additionals:(NSDictionary <NSString *, NSString *> *)additionals {
    self = [super init];
    if (self) {
        self.trackSystemIdentifiers = enableSystemIdentifierTracking;
        self.syncWithBackendFirst = ![additionals[secretOptionSyncWithBackendFirst] isEqualToString:@"false"];
        self.useJsonUrlSchemeSyncFormat = ![additionals[secretOptionUseJsonUrlSchemeSyncFormat] isEqualToString:@"false"];
        
        [SDKIntegrationValidator validateWithIdfa:self.trackSystemIdentifiers
                                  applicationName:appName
                                             cpid:cpid];
        
        [self setCpid:cpid];
        if (self.cpid == nil) {
            return nil;
        }
        [self setApplicationName:appName];
        if (self.applicationName == nil) {
            return nil;
        }
        
        frameworkInstance = self;
        
        if (!self.trackSystemIdentifiers) {
            [Logger logInfo:@[@"IDFA and IDFV tracking turned off"]];
        }
        
        self.trackingType = trackingType;
        self.isWebViewBased = webViewBased;
        self.additionals = additionals;
        [self setDeviceType];
        if (accessGroup) {
            [self setupKeychainItemWithAccessGroup:accessGroup];
        } else {
            [self saveUserId];
        }

        if ([self oldPanelUserInfoIsCached] || [self sifoInternetAppIsInstalled]) {
            [self callGetPanelistInfoWithAppName:appName additionals:additionals];
        }
    }

    [Logger logInfo:@[
        @"Framework initiated",
        [NSString stringWithFormat:@"CPID: '%@'", cpid],
        [NSString stringWithFormat:@"App name: '%@'", appName]
    ]];
    
    return self;
}

// Utility functions extracted from init
- (BOOL)oldPanelUserInfoIsCached {
    return [NSUserDefaults.standardUserDefaults valueForKey:userdefaultsCookieKey] != nil;
}

- (BOOL)sifoInternetAppIsInstalled {
    NSMutableString *application = [NSMutableString string];
    [application appendString:kInternetApplicationScheme];
    [application appendString:@"://"];
    [application appendString:@"sync/"];
    NSURL *url = [NSURL URLWithString:application];

    return url && [[UIApplication sharedApplication] canOpenURL:url];
}

- (void)callGetPanelistInfoWithAppName:(NSString *)appName additionals:(NSDictionary <NSString *, NSString *> *)additionals {
    // It is only possible to disable sync with backend first for SifoTest app.
    if (self.trackSystemIdentifiers && self.syncWithBackendFirst) {
        [NSURLSession.sharedSession syncWithSdkVersion:versionString
                                               appName:appName
                                              syncJson:[TSMobileAnalytics generateJSONForSyncWithAdditionals:additionals]
                                            completion:^(NSString *cookieKey, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil || cookieKey == nil) {
                    // Fallback to sync with panelist app.
                    if (![TSMobileAnalytics syncWithSIFOPanelenApplication]) {
                        [TSMobileAnalytics refreshCookiesWithCompletion:^{
                            [TSMobileAnalytics sendTagWithCategories:@[@"appstart"]
                                                           contentID:nil
                                                          completion:nil];
                        }];
                    }
                } else {
                    [TSMobileAnalytics updateCookieKey:cookieKey];
                    [TSMobileAnalytics refreshCookiesWithCompletion:^{
                        [TSMobileAnalytics sendTagWithCategories:@[@"appstart"]
                                                       contentID:nil
                                                      completion:nil];
                    }];
                    [Logger logInfo:@[@"Did sync with backend successfully."]];
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(![TSMobileAnalytics syncWithSIFOPanelenApplication]) {
                [TSMobileAnalytics refreshCookiesWithCompletion:^{
                    [TSMobileAnalytics sendTagWithCategories:@[@"appstart"]
                                                   contentID:nil
                                                  completion:nil];
                }];
            }
        });
    }

}

/** Save a unique userId to NSUserDefaults, without keychain sharing.
 * This userId is used as a query parameter with the tag requests.
 * Will persist this value in NSUserDefaults if no access group is provided in framework init.
 * Checks for a value, or creates if doesn't exist.
 */
- (void)saveUserId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UUID = [defaults stringForKey:userIDKey];
    if (UUID == nil || UUID.length <= 0) {
        UUID = [[NSUUID UUID] UUIDString];
        [defaults setObject:UUID forKey:userIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.mEuid = UUID;
}

- (void)setDeviceType {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.mref = [prefixIpad stringByAppendingString:self.applicationName];
    } else {
        self.mref = [prefixIphone stringByAppendingString:self.applicationName];
    }
}

- (void)setCpid:(NSString *)cpid {
    if (cpid != nil && cpid.length == cpidMaxLengthCodigo) {
        _cpid = cpid;
    }
}

- (void)setApplicationName:(NSString *)applicationName {
    if (applicationName != nil && [applicationName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length != 0) {
        _applicationName = applicationName;
    }
}

/** Used to share a unique user Id through several applications that have the same bundle seed. (<bundle>.<seed>.<bundleIdentifier>)
 * The user enabled keychain sharing for their apps, and sets a property to share and save a userId under.
 * @param keychainAccessGroup the name of the accessgroup (property) in keychain to read/write to.
 */
- (void)setupKeychainItemWithAccessGroup:(NSString *)keychainAccessGroup {
    self.keychainItemWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:userIDKey
                                                                   accessGroup:[self formattedAccessGroupFromAccessGroup:keychainAccessGroup]];
    
    NSData *UUIDdata = [self getKeychainUserId];
    if (UUIDdata == (id)[NSNull null] || UUIDdata.length == 0) {
        [self setupKeychainWrapperWithIdentifier:userIDKey
                             keychainAccessGroup:keychainAccessGroup];
    }
    self.mEuid = [[NSString alloc] initWithData:[self getKeychainUserId] encoding:NSUTF8StringEncoding];
}

/** Sync with Panelen/Internet app.
 * Checks if a sync should be done,
 * Returns if it needs sync
 */
+ (BOOL)syncWithSIFOPanelenApplication {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *previousVersion = [userDefaults valueForKey:userdefaultsSdkVersionKey];
    NSString *currentVersion = versionString;
    
    BOOL needsSync = NO;
    
    if (previousVersion == nil || ![previousVersion isEqualToString:currentVersion]) {
        needsSync = YES;
    }
    
    if (![TSMobileAnalytics panelistToken]) {
        needsSync = YES;
    }
    
    if ([TSMobileAnalytics applicationInstalled]) {
        if (needsSync) {
            [TSMobileAnalytics syncTokenWithPanelenAppWithAdditionals:frameworkInstance.additionals];
        }
    }
    
    return needsSync;
}

#pragma mark - Framework public methods

+ (TSMobileAnalytics *)sharedInstance {
    return frameworkInstance;
}

#pragma mark - Setters

+ (void)updateCookieKey:(NSString *)cookieKey {
    [NSUserDefaults.standardUserDefaults setValue:cookieKey forKey:userdefaultsCookieKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)refreshCookiesWithCompletion:(void (^)(void))completion {
    NSString *cookieKey = [NSUserDefaults.standardUserDefaults valueForKey:userdefaultsCookieKey];
    NSArray *cookies = [TSMobileAnalytics parseURLEncodedJSONCookie:cookieKey];
    
    [TSMobileAnalytics setCookiesWith:cookies completion:completion];
    [TSMobileAnalytics setLocalStorageWith:cookies];
}

+ (void)setLogPrintsActivated:(BOOL)active {
    [Logger printErrors:true];
    [Logger printWarnings:active];
    [Logger printInfo:active];
}

+ (void)addWebview:(WKWebView *)webview {
    if (webview) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [webviews addObject:webview];
            
            // Keep updating local storage values.
            // Local storage key values are removed by apple every so often because of privacy conserns.
            // So we need to keep setting them everytime.
            
            NSString *cookieKey = [[NSUserDefaults standardUserDefaults] valueForKey:userdefaultsCookieKey];
            NSArray *cookies = [TSMobileAnalytics parseURLEncodedJSONCookie:cookieKey];
            [TSMobileAnalytics setLocalStorageWith:cookies webview:webview];
        });
    }
}

+ (void)removeWebview:(WKWebView *)webview {
    if (webview) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [webviews removeObject:webview];
        });
    }
}

#pragma mark - Send tag

+ (void)sendTagWithCategories:(NSArray <NSString *> *)categories
                    contentID:(NSString *)contentID
                   completion:(void (^)(BOOL success, NSError *error))completionBlock {
    if (frameworkInstance == nil) {
        return;
    }
    
    if (frameworkInstance.trackingType == TrackPanelistsOnly && [TSMobileAnalytics panelistToken] == nil) {
        // No panelist token, but trackPanelistOnly selected; doing nothing.
        return;
    }
    
    [NSURLSession.sharedSession sendTagWithSdkVersion:versionString
                                           categories:categories
                                            contentId:contentID
                                            reference:frameworkInstance.mref
                                                 cpid:frameworkInstance.cpid
                                                 euid:frameworkInstance.mEuid
                                    trackPanelistOnly:frameworkInstance.trackingType == TrackPanelistsOnly
                                       isWebViewBased:frameworkInstance.isWebViewBased
                                           completion:completionBlock];
}

#pragma mark - SIFO Panelen/Internet sync

+ (void)syncSourceApplicationWithFrameWorkFromURL:(NSURL *)url {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:versionString forKey:userdefaultsSdkVersionKey];
    
    NSString *cookieKey = [url resourceSpecifier];
    
    // -- Save cookieKey if we got one
    if (cookieKey != nil && ![cookieKey isEqualToString:@""]) {
        [TSMobileAnalytics updateCookieKey:cookieKey];
        [TSMobileAnalytics refreshCookiesWithCompletion:^{
            [TSMobileAnalytics sendTagWithCategories:@[@"appstart"]
                                           contentID:nil
                                          completion:nil];
        }];
        
        [Logger logInfo:@[@"Did sync with panelist app successfully."]];
    } else {
        // -- We didn't get a cookieKey, to not inconvenience the user we save a timeout for when we should try again
        NSDate *nextSyncDate;
        NSDate *previousDate = [userDefaults valueForKey:userdefaultsLastSyncKey];
        
        if (previousDate == nil) {
            // -- roughly two weeks worth of seconds
            nextSyncDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*7*2];
        } else {
            // -- roughly three months worth of seconds
            nextSyncDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*7*4*3];
        }
        
        [userDefaults setValue:nextSyncDate forKey:userdefaultsLastSyncKey];
        [userDefaults synchronize];
    }
}

/** Parse a JSON-encoded cookie dictionary */

+ (NSArray  * _Nullable)parseURLEncodedJSONCookie:(NSString *)urlEncodedJsonString {
    if (urlEncodedJsonString != nil) {
        NSString *urlDecoded = [urlEncodedJsonString stringByRemovingPercentEncoding];
        NSData *jsonData = [urlDecoded dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
        if (error != nil) {
            [Logger logWarning:@[
                @"Parse json cookie failed",
                (error.description ? error.description : @"<description missing>")
            ]];
        }
        return json;
    }
    return nil;
}

+ (NSString * _Nullable)generateJSONForSyncWithAdditionals:(NSDictionary<NSString *, NSString *> *)additionals {
    NSString *advertisingIdentifier = [TSMobileAnalytics getAdvertisingIdentifier].UUIDString;
    NSString *vendorIdentifier = [TSMobileAnalytics getVendorIdentifier].UUIDString;
    
    id advertisingValue = (advertisingIdentifier != nil ? advertisingIdentifier : [NSNull null]);
    id vendorValue = (vendorIdentifier != nil ? vendorIdentifier : [NSNull null]);
    id additionalsValue = (additionals != nil ? additionals : @{});
    
    NSDictionary *content = @{
        @"appScheme":[TSMobileAnalytics panelenCookieExchangeURLScheme],
        @"keyValues":@{
                @"a0": advertisingValue,
                @"a1": vendorValue
        },
        @"additionalKeyValues": additionalsValue
    };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content
                                                       options:kNilOptions
                                                         error:&error];
    if (error != nil) {
        [Logger logWarning:@[
            @"Generate json for sync with panelist app failed",
            (error.description ? error.description : @"<description missing>")
        ]];
    }
    
    if (jsonData == nil) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (void)setCookiesWith:(NSArray *)cookies
            completion:(void (^)(void))completion {
    NSMutableArray <NSString *> *domains = [NSMutableArray new];
    
    if (cookies) {
        for (NSDictionary *cookie in cookies) {
            NSString *domain = cookie[@"domain"];
            if (domain != nil && [domain isKindOfClass:[NSString class]]) {
                [domains addObject:domain];
            }
        }
    }
    
    [CookieHelper deleteCookiesForDomains:domains completion:^{
        if (cookies) {
            for (NSDictionary *cookie in cookies) {
                [CookieHelper setCookieWithValue:cookie[@"value"]
                                          forKey:cookie[@"key"]
                                       andDomain:cookie[@"domain"]];
            }
        }
        
        NSString *settingCookieDomain = @".research-int.se";
        
        [CookieHelper setCookieWithBoolValue:frameworkInstance.trackingType == TrackPanelistsOnly forKey:@"trackPanelistOnly" andDomain:settingCookieDomain];
        [CookieHelper setCookieWithBoolValue:frameworkInstance.isWebViewBased forKey:@"isWebViewBased" andDomain:settingCookieDomain];
        [CookieHelper setCookieWithValue:versionString forKey:@"sdkVersion" andDomain:settingCookieDomain];
        [CookieHelper setCookieWithValue:[NSBundle appVersionString] forKey:@"appVersion" andDomain:settingCookieDomain];
        
        [CookieHelper setCookieWithValue:[NSString stringWithFormat:@"trackPanelistOnly=%@&isWebViewBased=%@&sdkVersion=%@",
                                          (frameworkInstance.trackingType == TrackPanelistsOnly ? @"true" : @"false"),
                                          (frameworkInstance.isWebViewBased ? @"true" : @"false"),
                                          versionString]
                                  forKey:@"sifo_config"
                               andDomain:settingCookieDomain];
        
        if (completion) {
            completion();
        }
    }];
}

+ (void)setLocalStorageWith:(NSArray *)cookies {
    for (WKWebView *webview in webviews) {
        [self setLocalStorageWith:cookies webview:webview];
    }
}

+ (void)setLocalStorageWith:(NSArray *)cookies
                    webview:(WKWebView *)webview {
    NSString *settingCookieDomain = @".research-int.se";
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObjectsFromArray:cookies];
    
    [values addObject:@{
        @"key": @"trackPanelistOnly",
        @"domain": settingCookieDomain,
        @"value": (frameworkInstance.trackingType == TrackPanelistsOnly ? @"true" : @"false"),
    }];
    
    [values addObject:@{
        @"key": @"isWebViewBased",
        @"domain": settingCookieDomain,
        @"value": (frameworkInstance.isWebViewBased ? @"true" : @"false"),
    }];
    
    [values addObject:@{
        @"key": @"sdkVersion",
        @"domain": settingCookieDomain,
        @"value": versionString,
    }];
    
    [values addObject:@{
        @"key": @"sifo_config",
        @"domain": settingCookieDomain,
        @"value": [NSString stringWithFormat:@"trackPanelistOnly=%@&isWebViewBased=%@&sdkVersion=%@",
                   (frameworkInstance.trackingType == TrackPanelistsOnly ? @"true" : @"false"),
                   (frameworkInstance.isWebViewBased ? @"true" : @"false"),
                   versionString],
    }];
    
    [webview setLocalStorageWithCookies:values];
}

+ (id)panelistToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:userdefaultsCookieKey];
}

/**
 * @method Call this method to determine if device has Sifo Internet || Sifo Panelen application installed
 * @return BOOL checks if either Sifo Internet || Sifo Panelen application is installed on device
 */
+ (BOOL)applicationInstalled {
    return [self isApplicationInstalled:kInternetApplicationScheme];
}

/**
 * @method Call this method to determine if application is installed
 * @param application Scheme for application
 * @return BOOL checks if application with Scheme is installed
 */
+ (BOOL)isApplicationInstalled:(NSString *)application {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSMutableString *applicationURL = [NSMutableString string];
    [applicationURL appendString:application];
    [applicationURL appendString:@"://"];
    [applicationURL appendString:bundleIdentifier];
    
    return [sharedApplication canOpenURL:[NSURL URLWithString:applicationURL]];
}

/**
 The single source of truth for the URL scheme used for cookie exchange.
 */

+ (NSString*)panelenCookieExchangeURLScheme {
    return [NSBundle.mainBundle appExchangeScheme].lowercaseString;
}

/**
 * @method Call this to sync Application with Framework
 */
+ (void)syncTokenWithPanelenAppWithAdditionals:(NSDictionary <NSString *, NSString *> *)additionals {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *now = [NSDate date];
    NSDate *nextSyncDate = [userDefaults valueForKey:userdefaultsLastSyncKey];
    
    BOOL syncTooOften = true;
    
    if ([now laterDate:nextSyncDate] == now || nextSyncDate == nil) {
        syncTooOften = false;
    }
    
    if (!syncTooOften) {
        NSMutableString *application = [NSMutableString string];
        [application appendString:kInternetApplicationScheme];
        [application appendString:@"://"];
        [application appendString:@"sync/"];
        
        // Option could only be set to false by Sifo test app.
        // To test old sync format without json.
        if (frameworkInstance.useJsonUrlSchemeSyncFormat) {
            NSString *json = [[TSMobileAnalytics generateJSONForSyncWithAdditionals:additionals] urlEncoded];
            if (json != nil) {
                [application appendString:json];
            }
        } else {
            [application appendString:[TSMobileAnalytics panelenCookieExchangeURLScheme]];
        }
        
        NSURL *url = [NSURL URLWithString:application];
        if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:application]
                                               options:@{}
                                     completionHandler:^(BOOL success) {}];
        }
    }
}

#pragma mark - Keychain Sharing

- (KeychainItemWrapper *)keychainItemWrapper {
    if (!_keychainItemWrapper) {
        self.keychainItemWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:userIDKey accessGroup:nil];
    }
    return _keychainItemWrapper;
}

- (NSData *)getKeychainUserId {
    return [self.keychainItemWrapper objectForKey:(id)kSecValueData];
}

- (void)setupKeychainWrapperWithIdentifier:(NSString *)identifier keychainAccessGroup:(NSString *)accessGroup {
    
    NSData *keychainItemID = [NSData dataWithBytes:userIDKey
                                            length:strlen([userIDKey cStringUsingEncoding:NSASCIIStringEncoding])];
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSData *uuidData = [uuid dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.keychainItemWrapper setObject:[self formattedAccessGroupFromAccessGroup:accessGroup] forKey:(id)kSecAttrAccessGroup];
    [self.keychainItemWrapper setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [self.keychainItemWrapper setObject:keychainItemID forKey:(id)kSecAttrAccount];
    [self.keychainItemWrapper setObject:kServiceName forKey:(id)kSecAttrService];
    [self.keychainItemWrapper setObject:uuidData forKey:(id)kSecValueData];
}

/**
 * This method retrieves the bundleSeedID from a previous keychain item.
 * Needed to create the access group id.
 * Creates one if it doesn't previously exists.
 */

- (NSString *)getBundleSeedID {
    
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess) {
        return nil;
    }
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    
    return bundleSeedID;
}

/**
 * Concatenates bundleSeedId and bundle seed.
 */
- (NSString *)formattedAccessGroupFromAccessGroup:(NSString *)accessGroup {
    NSString *bundleSeedId = [self getBundleSeedID];
    return [NSString stringWithFormat:@"%@.%@", bundleSeedId, accessGroup];
}

#pragma mark - Advertising Identifiers

+ (NSUUID *)getAdvertisingIdentifier {
    NSUUID *uuid = nil;
    if (frameworkInstance.trackSystemIdentifiers) {
        if (@available(iOS 14, *)) {
            uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        } else {
            if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
                uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
            }
        }
        
        if (uuid != nil && [uuid.UUIDString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            uuid = nil;
        }
    }
    return uuid;
}

+ (NSUUID *)getVendorIdentifier {
    if (frameworkInstance.trackSystemIdentifiers) {
        return [[UIDevice currentDevice] identifierForVendor];
    }
    return nil;
}

#pragma mark -
#pragma mark UIApplicationDelegate helpers

+ (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if([[url.scheme lowercaseString] isEqualToString:[TSMobileAnalytics panelenCookieExchangeURLScheme]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [TSMobileAnalytics syncSourceApplicationWithFrameWorkFromURL:url];
        });
    }
    return YES;
}

@end
