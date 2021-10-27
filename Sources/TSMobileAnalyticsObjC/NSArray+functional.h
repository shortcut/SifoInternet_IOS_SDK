//
//  NSArray+functional.h
//  SIFOTestApp
//
//  Created by Andrew Bulhak on 2020-03-27.
//  Copyright © 2020 Dynamo. All rights reserved.
//

#ifndef NSArray_functional_h
#define NSArray_functional_h
#import <Foundation/Foundation.h>

// Some functional-ish utility functions for NSArray. These are implemented as functions, for ease of linking against the static library.

NSArray *filterArray(NSArray *input, BOOL (^predicate)(id item));

#endif /* NSArray_functional_h */
