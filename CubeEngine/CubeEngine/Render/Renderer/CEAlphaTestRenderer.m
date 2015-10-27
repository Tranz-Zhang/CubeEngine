//
//  CEAlphaTestRenderer.m
//  CubeEngine
//
//  Created by chance on 10/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEAlphaTestRenderer.h"
#import "CERenderer_privates.h"


@implementation CEAlphaTestRenderer

- (BOOL)onPrepareRendering {
    if([super onPrepareRendering]) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        return YES;
    }
    return NO;
}


- (void)onFinishRendering:(BOOL)hasRenderAllObjects {
    glDisable(GL_BLEND);
}

@end
