//
//  NSURLSession+Sifo.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-27.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import "NSURLSession+Sifo.h"
#import "NSArray+functional.h"
#import "NSBundle+Sifo.h"
#import "NSString+Encoding.h"
#import "TSMobileAnalyticsConstants.h"
#import "Logger.h"

@implementation NSURLSession (sifo)

- (void)sendTagWithSdkVersion:(NSString *)sdkVersion
                   categories:(NSArray <NSString *> *)categories
                    contentId:(NSString *)contentId
                    reference:(NSString *)reference
                         cpid:(NSString *)cpid
                         euid:(NSString *)euid
            trackPanelistOnly:(BOOL)trackPanelistOnly
               isWebViewBased:(BOOL)isWebViewBased
                   completion:(void (^)(BOOL success, NSError *error))completionBlock {
    
    NSString *category = [NSURLSession generateCategoryStringFromArray:categories];
    int result = [NSURLSession validateInputParametersWithCategory:category
                                                         contentID:contentId];
    if (result == TSInputSuccess) {
        [[self dataTaskWithURL:[NSURL URLWithString:[NSURLSession getURLWithSdkVersion:sdkVersion
                                                                            categories:category
                                                                             contentId:contentId
                                                                             reference:reference
                                                                                  cpid:cpid
                                                                                  euid:euid
                                                                     trackPanelistOnly:trackPanelistOnly
                                                                        isWebViewBased:isWebViewBased]]
             completionHandler:^(NSData *data,
                                 NSURLResponse *response,
                                 NSError *error) {
            if (error) {
                [Logger logWarning:@[
                    @"Failed to send tag:",
                    (error.description ? error.description : @"<description missing>")
                ]];
                
                if (completionBlock) {
                    completionBlock(NO, error);
                }
            } else if (completionBlock) {
                [Logger logInfo:@[
                    @"Tag sent"
                ]];
                
                completionBlock(YES, nil);
            }
        }] resume];
    } else if(completionBlock) {
        NSError *error = [NSError errorWithDomain:@"TSMobileAnalytics"
                                             code:result
                                         userInfo:@{NSLocalizedDescriptionKey:[NSURLSession validationErrorMessageForStatus:result]}];
        
        [Logger logWarning:@[
            @"Failed to send tag:",
            (error.description ? error.description : @"<description missing>")
        ]];
        
        completionBlock(FALSE, error);
    }
}

- (void)syncWithSdkVersion:(NSString *)sdkVersion
                   appName:(NSString *)appName
                  syncJson:(NSString *)syncJson
                completion:(void (^)(NSString *cookieKey, NSError *error))completionBlock {
    
    NSString *url = [sifoBaseURL stringByAppendingString:@"/GetPanelistInfo"];
    NSMutableArray <NSString *> *params = [NSMutableArray new];
    
    if (sdkVersion != nil) {
        [params addObject:[NSString stringWithFormat:@"sdkversion=%@", [sdkVersion urlEncoded]]];
    }
    
    if (appName != nil) {
        [params addObject:[NSString stringWithFormat:@"appname=%@", [appName urlEncoded]]];
    }
    
    if (syncJson != nil) {
        [params addObject:[NSString stringWithFormat:@"SifoAppFrameworkInfo=%@", [syncJson urlEncoded]]];
    }
    
    if (params.count > 0) {
        url = [url stringByAppendingFormat:@"?%@", [params componentsJoinedByString:@"&"]];
    }
    
    [[self dataTaskWithURL:[NSURL URLWithString:url]
         completionHandler:^(NSData *data,
                             NSURLResponse *response,
                             NSError *error) {
        if (error) {
            [Logger logWarning:@[
                @"Failed to sync with backend:",
                (error.description ? error.description : @"<description missing>")
            ]];
            
            if (completionBlock) {
                completionBlock(nil, error);
            }
        } else {
            [NSURLSession parseSyncData:data
                             completion:^(NSString *cookieKey, NSError *error) {
                if (error != nil) {
                    [Logger logWarning:@[
                        @"Failed to parse json when syncing with backend:",
                        (error.description ? error.description : @"<description missing>")
                    ]];
                    
                    if (completionBlock) {
                        completionBlock(nil, error);
                    }
                }
                else if (completionBlock) {
                    completionBlock(cookieKey, nil);
                }
            }];
        }
    }] resume];
}

+ (void)parseSyncData:(NSData *)data
           completion:(void (^)(NSString *cookieKey, NSError *error))completionBlock {
    NSString *jsonStr = nil;
    
    if (data != nil) {
        jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    if (jsonStr != nil) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (error != nil) {
            completionBlock(nil, error);
        }
        else if (json != nil && [json isKindOfClass:[NSDictionary class]]) {
            id cookies = json[@"CookieInfos"];
            if ([NSURLSession validateCookiesArray:cookies]) {
                NSString *cookieKey = [self toURLEncodedJson:cookies];
                if (cookieKey) {
                    if (completionBlock) {
                        completionBlock(cookieKey, nil);
                    }
                } else if (completionBlock) {
                    completionBlock(nil, [NSError errorWithDomain:@"TSMobileAnalytics"
                                                             code:0
                                                         userInfo:@{NSLocalizedDescriptionKey:@"Unable to serialize cookies"}]);
                }
            } else if (completionBlock) {
                if (cookies == [NSNull null]) {
                    completionBlock(nil, nil);
                } else {
                    completionBlock(nil, [NSError errorWithDomain:@"TSMobileAnalytics"
                                                             code:0
                                                         userInfo:@{NSLocalizedDescriptionKey:@"Cookies invalid"}]);
                }
            }
        } else if(completionBlock) {
            completionBlock(nil, [NSError errorWithDomain:@"TSMobileAnalytics"
                                                     code:0
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Cookies invalid format"}]);
        }
    } else if (completionBlock) {
        completionBlock(nil, [NSError errorWithDomain:@"TSMobileAnalytics"
                                                 code:0
                                             userInfo:@{NSLocalizedDescriptionKey:@"No cookies found"}]);
    }
}

+ (NSString *)toURLEncodedJson:(id)object {
    NSData *cookiesData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString *cookiesStr = [[NSString alloc] initWithData:cookiesData encoding:NSUTF8StringEncoding];
    return [cookiesStr urlEncoded];
}

+ (BOOL)validateCookiesArray:(NSArray *)cookies {
    // Cookies may be a empty array. If it is, it means we clear all cookies for that panelist.
    // Cookies may be nil. If they are it means we should re-sync with Panelist app.
    if (cookies == nil) {
        return YES;
    }
    
    if (![cookies isKindOfClass:[NSArray class]]) {
        return NO;
    }

    for (id cookie in cookies) {
        if (![cookie isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        
        // Domain is required and must be a string.
        if (cookie[@"domain"] == nil || ![cookie[@"domain"] isKindOfClass:[NSString class]]) {
            return NO;
        }
        
        // Key is required and must be a string.
        if (cookie[@"key"] == nil || ![cookie[@"key"] isKindOfClass:[NSString class]]) {
            return NO;
        }
        
        // Value is required and must be a string.
        if (cookie[@"value"] == nil || ![cookie[@"value"] isKindOfClass:[NSString class]]) {
            return NO;
        }
        
        // Path is optional, but must be a type of string.
        if (cookie[@"path"] != nil && ![cookie[@"path"] isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    
    return YES;
}

+ (NSString *)getURLWithSdkVersion:(NSString *)sdkVersion
                        categories:(NSString *)categories
                         contentId:(NSString *)contentId
                         reference:(NSString *)reference
                              cpid:(NSString *)cpid
                              euid:(NSString *)euid
                 trackPanelistOnly:(BOOL)trackPanelistOnly
                    isWebViewBased:(BOOL)isWebViewBased {
    NSString *cat = categories;
    NSString *ref = reference;
    NSString *id_code = contentId;
    NSString *type = @"application";
    
    if (cat == nil) {
        cat = @"";
    } else {
        cat = [cat stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        cat = [cat stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    }
    
    if (ref == nil) {
        ref = @"";
    } else {
        ref = [ref stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    }
    
    if (id_code == nil) {
        id_code = @"";
    } else {
        id_code = [id_code stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    }

    NSString *appVersionString = [[NSBundle appVersionString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *url;
    
    url = [NSString stringWithFormat:@"%@siteId=%@&appClientId=%@&cp=%@&appId=%@&appName=%@&appRef=%@&TrackPanelistsOnly=%s&IsWebViewBased=%s&appVersion=%@",
           codigoBaseURL, cpid, euid, cat, id_code, type, ref,
           trackPanelistOnly ? "true" : "false",
           isWebViewBased ? "true" : "false",
           appVersionString];
    
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&session=sdk_%@", sdkVersion]];
    
    return url;
}

+ (NSString * __nullable)validationErrorMessageForStatus:(int)status {
    switch(status) {
        case TSInputCategoryNil:
            return @"Category is nil";
        case TSInputCategoryTooLong:
            return @"category string too long (may contain no more than 255 characters).";
        case TSInputContentIdTooLong:
            return @"contentId string too long (may contain no more than 255 characters).";
        case TSInputContentNameTooLong:
            return @"content name string too long (may contain no more than 255 characters).";
        case TSInputPanelistIdMissing:
            return @"panelist ID is nil";
        default:
            return nil;
    }
}

+ (int)validateInputParametersWithCategory:(NSString *)category
                                 contentID:(NSString *)contentID {
    int result;
    if (category == nil) {
        result = TSInputCategoryNil;
    } else if (category.length > categoryMaxLength) {
        result = TSInputCategoryTooLong;
    } else if (contentID.length > contentMaxLength) {
        result = TSInputContentIdTooLong;
    } else {
        result = TSInputSuccess;
    }
    return result;
}

+ (NSString *)generateCategoryStringFromArray:(NSArray <NSString *> *)categories {
    return [filterArray(categories, ^BOOL(NSString * item) {
        return [item length]>0;
    })  componentsJoinedByString:@"/"];
}

@end
