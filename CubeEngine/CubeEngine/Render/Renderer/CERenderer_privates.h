//
//  CERenderer_privates.h
//  CubeEngine
//
//  Created by chance on 10/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CEShaderProgram.h"

@interface CERenderer ()

- (void)setShaderProgram:(CEShaderProgram *)shaderProgram;


#pragma mark - template methods

/**
 Called before renderObject:, use to setup the program before render objects
 */
- (BOOL)onPrepareRendering;

/**
 Called for every renderObject
 */
- (BOOL)renderObject:(CERenderObject *)renderObject;

/**
 Called after finish render objects
 */
- (void)onFinishRendering:(BOOL)hasRenderAllObjects;


#pragma mark - Assist methods
/**
 load texture with the specify id into texture unit in gpu.
 @return texture unit, return -1 if fail to load texture.
 */
- (GLint)loadTextureWithID:(uint32_t)textureID;

@end
