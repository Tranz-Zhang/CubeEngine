//
//  CERenderableTextureBuffer.h
//  CubeEngine
//
//  Created by chance on 10/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CETextureBuffer.h"

/**
 used for rendering depth buffer to a texture
 */
@interface CEDepthTextureBuffer : CETextureBuffer

- (BOOL)beginRendering;
- (void)endRendering;

@end
