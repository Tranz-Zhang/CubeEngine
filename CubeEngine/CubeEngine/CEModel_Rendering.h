//
//  CEObject_Rendering.h
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEModel.h"
#import "CEProgram.h"

@interface CEModel ()

// current model transform
@property (nonatomic, readonly) GLKMatrix4 transformMatrix;

// an auto generated vertex buffer in OpenGLES
@property (nonatomic, readonly) GLuint vertexBufferIndex;

// number of vertext in model
@property (atomic, readonly) GLsizei vertextCount;

- (void)generateVertexBufferInContext:(EAGLContext *)context;

@end

