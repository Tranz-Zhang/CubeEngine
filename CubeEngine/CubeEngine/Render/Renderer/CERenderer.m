//
//  CERenderer.m
//  CubeEngine
//
//  Created by chance on 10/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CERenderer_privates.h"
#import "CETextureManager.h"

@implementation CERenderer

- (void)setShaderProgram:(CEShaderProgram *)shaderProgram {
    _program  = shaderProgram;
}


- (BOOL)renderObjects:(NSArray *)objects {
    if (!_program || !_camera) {
        CEError(@"Invalid renderer environment");
        return NO;
    }
    [_program use];
    if (![self onPrepareRendering]) {
        CEError(@"Fail to prepare rendering");
        return NO;
    }
    BOOL isOK = YES;
    for (CERenderObject *renderObject in objects) {
        BOOL success = [self renderObject:renderObject];
        if (!success) {
            isOK = NO;
        }
    }
    [self onFinishRendering:isOK];
    return isOK;
}


#pragma mark - template methods

- (BOOL)onPrepareRendering {
    return NO;
}


- (BOOL)renderObject:(CERenderObject *)renderObject {
    return NO;
}

- (void)onFinishRendering:(BOOL)hasRenderAllObjects {
    
}


#pragma mark - Assist methods

- (GLint)loadTextureWithID:(uint32_t)textureID {
    return [[CETextureManager sharedManager] prepareTextureWithID:textureID];
}


@end
