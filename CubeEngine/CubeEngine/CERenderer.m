//
//  CERenderer.m
//  CubeEngine
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CEProgram.h"

NSString *const kTestVertexShader = SHADER_STRING
(
 attribute highp vec4 position;
 uniform mat4 projection;
 
 void main () {
     gl_Position = projection * position;
 }
);

NSString *const kTestFragmentSahder = SHADER_STRING
(
 uniform lowp vec4 drawColor;
 void main() {
     gl_FragColor = drawColor;
 }
);

@implementation CERenderer {
    CEProgram *_program;
    GLuint _vertexBuffer;
    
    GLint _attribPosition;
    GLint _uniformProjection;
    GLint _uniformDrawColor;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupOpenGL];
    }
    return self;
}


- (void)setupOpenGL {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            GEPrintf("Fail to init context");
            return;
        }
    }
    
    [EAGLContext setCurrentContext:_context];
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kTestVertexShader
                                        fragmentShaderString:kTestFragmentSahder];
    if (!_program.initialized) {
        [_program addAttribute:@"position"];
        if (![_program link])
        {
            NSString *progLog = [_program programLog];
            CELog(@"Program link log: %@", progLog);
            NSString *fragLog = [_program fragmentShaderLog];
            CELog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [_program vertexShaderLog];
            CELog(@"Vertex shader compile log: %@", vertLog);
            return;
            
        } else {
            _attribPosition = [_program attributeIndex:@"position"];
            _uniformProjection = [_program uniformIndex:@"projection"];
            _uniformDrawColor = [_program uniformIndex:@"drawColor"];
        }
    }
}

- (void)renderObject:(CEObject *)object {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [EAGLContext setCurrentContext:_context];
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, object.vertexData.length, object.vertexData.bytes, GL_STATIC_DRAW);
    glEnableVertexAttribArray(_attribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, 0);
    [_program use];
    
    // projection
    float aspect = fabsf(320.0f / 568.0f);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, 0.1, 100);
    projectionMatrix = GLKMatrix4Translate(projectionMatrix, 0, 0, -4);
    projectionMatrix = GLKMatrix4Multiply(projectionMatrix, object.transformMatrix);
    
    glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
    glUniform4f(_uniformDrawColor, 0.6, 0.6, 0.6, 1.0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glLineWidth(2.0f);
    glUniform4f(_uniformDrawColor, 1, 1, 1, 1.0);
    glDrawArrays(GL_LINES, 0, 36);
}


@end
