//
//  CEWireFrame_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEWireFrame.h"

@interface CEWireFrame ()

// vertex buffer
@property (nonatomic, readonly) NSData *vertexData;
@property (nonatomic, readonly) GLuint vertexBufferIndex;

// setup vertex buffer in opengles
- (void)setupArrayBuffersWithContext:(EAGLContext *)context;

@end
