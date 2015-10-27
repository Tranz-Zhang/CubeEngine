//
//  CETransparentRenderer.m
//  CubeEngine
//
//  Created by chance on 10/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CETransparentRenderer.h"
#import "CERenderer_privates.h"

@implementation CETransparentRenderer

- (BOOL)onPrepareRendering {
    if([super onPrepareRendering]) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_CULL_FACE);
        return YES;
    }
    return NO;
}


- (BOOL)renderObject:(CERenderObject *)renderObject {
    glCullFace(GL_FRONT);
    if (![super renderObject:renderObject]) {
        return NO;
    }
    glCullFace(GL_BACK);
    if (![super renderObject:renderObject]) {
        return NO;
    }
    return YES;
}


- (void)onFinishRendering:(BOOL)hasRenderAllObjects {
    glDisable(GL_CULL_FACE);
    glDisable(GL_BLEND);
}


@end
