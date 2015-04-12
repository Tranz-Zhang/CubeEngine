//
//  CEBaseRender.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"



@implementation CERenderer

- (BOOL)setupRenderer {
    // !!!: MUST IMPLEMENTED BY SUBCLASS
    return NO;
}

- (void)renderObject:(id)object {
    // !!!: MUST IMPLEMENTED BY SUBCLASS
}

@end
