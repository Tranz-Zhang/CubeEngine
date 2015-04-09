//
//  CEBaseRender.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEBaseRender.h"



@implementation CEBaseRender

- (BOOL)prepareRender {
    // !!!: MUST IMPLEMENTED BY SUBCLASS
    return NO;
}

- (void)renderModel:(CEModel *)model {
    // !!!: MUST IMPLEMENTED BY SUBCLASS
}

@end
