//
//  GLCoordinateDrawer.m
//  CubeEngine
//
//  Created by chance on 15/3/16.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CECoordinateRenderer.h"
#import "CELinesProgram.h"

NSString *const kLinesVertexShader = CE_SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 vertexColor;
 
 uniform mat4 projection;
 
 varying lowp vec4 lineColor;
 
 void main () {
     lineColor = vertexColor;
     gl_Position = projection * position;
 }
 );

NSString *const kLinesFragmentSahder = CE_SHADER_STRING
(
 varying lowp vec4 lineColor;
 void main() {
     gl_FragColor = lineColor;
 }
 );


GLfloat kCoordinateLineData[42] =
{
    // Position + Color
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // Axis X
    1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // Axis X
    
    0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, // Axis Y
    0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, // Axis Y
    
    0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, // Axis Z
    0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f  // Axis Z
};


@implementation CECoordinateRenderer {
    EAGLContext *_context;
    CEProgram *_program;
    GLint _attributePosition;
    GLint _attributeVertexColor;
    GLint _uniformProjection;
    GLuint _coordinateBuffer;
    
    NSMutableArray *_models;
    NSData *_vertextData;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        _models = [NSMutableArray array];
        
        [EAGLContext setCurrentContext:_context];
        [self setupProgram];
        
        // setup vertex buffer
        glGenBuffers(1, &_coordinateBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _coordinateBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(kCoordinateLineData), kCoordinateLineData, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(_attributePosition);
        glVertexAttribPointer(_attributePosition, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), CE_BUFFER_OFFSET(0));
        glEnableVertexAttribArray(_attributeVertexColor);
        glVertexAttribPointer(_attributeVertexColor, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), CE_BUFFER_OFFSET(3 * sizeof(GLfloat)));
    }
    return self;
}


- (void)setupProgram {
    _program = [[CEProgram alloc] initWithVertexShaderString:kLinesVertexShader
                                        fragmentShaderString:kLinesFragmentSahder];
    
    if (_program.initialized) {
        return;
    }
    [_program addAttribute:@"position"];
    [_program addAttribute:@"vertexColor"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attributePosition = [_program attributeIndex:@"position"];
        _attributeVertexColor = [_program attributeIndex:@"vertexColor"];
        _uniformProjection = [_program uniformIndex:@"projection"];
        
    } else {
        // print error info
        NSString *progLog = [_program programLog];
        CEError(@"Program link log: %@", progLog);
        NSString *fragLog = [_program fragmentShaderLog];
        CEError(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [_program vertexShaderLog];
        CEError(@"Vertex shader compile log: %@", vertLog);
    }
}


#pragma mark - Setters & Getters
- (void)setShowWorldCoordinate:(BOOL)showWorldCoordinate {
    if (_showWorldCoordinate != showWorldCoordinate) {
        _showWorldCoordinate = showWorldCoordinate;
    }
}

- (void)addModel:(CEModel_Deprecated *)model {
    if ([model isKindOfClass:[CEModel_Deprecated class]]) {
        [_models addObject:model];
    }
}

- (void)removeModel:(CEModel_Deprecated *)model {
    if ([model isKindOfClass:[CEModel_Deprecated class]]) {
        [_models removeObject:model];
    }
}



- (void)render {
    [EAGLContext setCurrentContext:_context];
    for (CEModel_Deprecated *model in _models) {
        [self drawCoordinateLinesWithTransformMatrix:model.transformMatrix];
    }
    
    if (_showWorldCoordinate) {
        [self drawCoordinateLinesWithTransformMatrix:GLKMatrix4Identity];
    }
}


- (void)drawCoordinateLinesWithTransformMatrix:(GLKMatrix4)transformMatrix {
    glBindBuffer(GL_ARRAY_BUFFER, _coordinateBuffer);
    glEnableVertexAttribArray(_attributePosition);
    // ???: why
    glVertexAttribPointer(_attributePosition, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), CE_BUFFER_OFFSET(0));
    
    [_program use];
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_cameraProjectionMatrix, transformMatrix);
    glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
    
    glDrawArrays(GL_LINES, 0, 6);
}

@end


