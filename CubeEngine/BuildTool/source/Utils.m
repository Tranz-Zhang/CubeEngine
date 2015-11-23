//
//  Utils.m
//  CubeEngine
//
//  Created by chance on 10/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "Utils.h"

// use DJBHash
uint32_t HashValueWithString(NSString *string) {
    uint32_t hash = 5381;
    for(size_t i = 0; i < string.length; i++) {
        hash = ((hash << 5) + hash) + [string characterAtIndex:i];
    }
    return (hash & 0x7FFFFFFF);
}


BOOL IsPowerOfTwo(uint32_t value) {
    return ((value != 0) && !(value & (value - 1)));
}

