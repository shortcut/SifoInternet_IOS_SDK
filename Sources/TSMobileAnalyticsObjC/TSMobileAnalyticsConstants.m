#import "TSMobileAnalyticsConstants.h"

int const cpidMaxLengthCodigo = 32;

int const appNameMaxLength = 244;
int const categoryMaxLength = 255;
int const extraMaxLength = 100;
int const contentMaxLength = 255;

NSString * const prefixIpad = @"APP_IPAD_";
NSString * const prefixIphone = @"APP_IPHONE_";

NSString * const sifoBaseURL = @"https://sifopanelen.research-int.se/App";
NSString * const codigoBaseURL = @"https://trafficgateway.research-int.se/TrafficCollector?";
NSString * const taggingEuidq = @"ext-id-returning";
NSString * const userIDKey = @"tns-sifo-device-id";

NSString * const userdefaultsCookieKey = @"se.tns-sifo.cookiekey";
NSString * const userdefaultsSdkVersionKey = @"se.tns-sifo.versionkey";
NSString * const userdefaultsTrackingStatusKey = @"se.tns-sifo.trackingStatusKey";
NSString * const userdefaultsLastSyncKey = @"se.tns-sifo.lastpanelensyncdate";

NSString * const secretOptionSyncWithBackendFirst = @"se.tns-sifo.syncWithBackendFirst";
NSString * const secretOptionUseJsonUrlSchemeSyncFormat = @"se.tns-sifo.useJsonUrlSchemeSyncFormat";
NSString * const secretOptionForceReinitialize = @"se.tns-sifo.forceReinitialize";

NSString * const kPanelenApp = @"se.tns-sifo.panelen";
NSString * const kInternetApp = @"se.tns-sifo.internet";

NSString * const kServiceName = @"tnssifo-mobile-tagging";

NSString * const kInternetApplicationScheme = @"se.tns-sifo.internetpanelen";

NSString * const kExchangeURLSchemeSuffix = @".tsmobileanalytics";
