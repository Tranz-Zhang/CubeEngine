//
//  CustomCodingObject.m
//  CEDatabase
//
//  Created by chance on 14-8-15.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "CustomCodingObject.h"

#define CODING_KEY_CODING_NAME @"CustomCodingObject.codingName"
#define CODING_KEY_CODING_DATE @"CustomCodingObject.codingDate"
#define CODING_KEY_VALUE @"CustomCodingObject.value"

@implementation CustomCodingObject

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _codingName = [aDecoder decodeObjectForKey:CODING_KEY_CODING_NAME];
        _codingDate = [aDecoder decodeObjectForKey:CODING_KEY_CODING_DATE];
        _value = [aDecoder decodeIntForKey:CODING_KEY_VALUE];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_codingName forKey:CODING_KEY_CODING_NAME];
    [aCoder encodeObject:_codingDate forKey:CODING_KEY_CODING_DATE];
    [aCoder encodeInt:_value forKey:CODING_KEY_VALUE];
}

@end
