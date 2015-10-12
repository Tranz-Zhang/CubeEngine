//
//  MTLInfo.m
//  CubeEngine
//
//  Created by chance on 9/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "MTLInfo.h"

static uint32_t sNextResourceID = kBaseMaterialID;

@implementation MTLInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _resourceID = sNextResourceID++;
    }
    return self;
}

@end
