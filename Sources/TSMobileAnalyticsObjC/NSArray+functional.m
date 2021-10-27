//
//  NSArray+functional.m
//  SIFOTestApp
//
//  Created by Andrew Bulhak on 2020-03-27.
//  Copyright © 2020 Dynamo. All rights reserved.
//


#import "NSArray+functional.h"

NSArray *filterArray(NSArray *input, BOOL (^predicate)(id item)) {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[input count]];
    for (id obj in input) {
        if (predicate(obj)) {
            [result addObject:obj];
        }
    }
    return result;
}
