//
//  NSString+Encoding.m
//  TSMobileAnalytics
//
//  Created by Christer Ulfsparre on 2020-10-27.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#import "NSString+Encoding.h"

@implementation NSString (encoding)

- (NSString *)urlEncoded {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
