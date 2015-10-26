//
//  CERenderer_Accessory.m
//  CubeEngine
//
//  Created by chance on 4/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEAssistRenderer.h"
#import "CEProgram.h"
#import "CECamera_Rendering.h"
#import "CELight_Rendering.h"
#import "CEModel.h"

NSString *const kAccessoryVertexShader = CE_SHADER_STRING
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

NSString *const kAccessoryFragmentSahder = CE_SHADER_STRING
(
 varying lowp vec4 lineColor;
 void main() {
     gl_FragColor = lineColor;
 }
);


@implementation CEAssistRenderer {
    CEProgram *_program;
    GLint _attributePosition;
    GLint _attributeVertexColor;
    GLint _uniformProjection;
    GLuint _vertexBufferIndex;
    GLuint _indicesBufferIndex;
    
    GLuint _worldOriginVertexBufferIndex;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupRenderer];
    }
    return self;
}


- (void)dealloc {
    if (_indicesBufferIndex) {
        glDeleteBuffers(1, &_indicesBufferIndex);
        _indicesBufferIndex = 0;
    }
    
    if (!_worldOriginVertexBufferIndex) {
        glDeleteBuffers(1, &_worldOriginVertexBufferIndex);
        _worldOriginVertexBufferIndex = 0;
    }
}

- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kAccessoryVertexShader
                                        fragmentShaderString:kAccessoryFragmentSahder];
    [_program addAttribute:@"position" atIndex:CEVBOAttributePosition];
    [_program addAttribute:@"vertexColor" atIndex:CEVBOAttributeColor];
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
        _program = nil;
        NSAssert(0, @"Fail to Compile Program");
    }
    
    return isOK;
}

// data struct: position[3] color[4]

- (void)renderBoundsForObjects:(NSArray *)objects {
    if (!_program.initialized) {
        return;
    }
    
    [_program use];
    glLineWidth(1.0);
    for (CEModel *model in objects) {
        [self renderBoundsWithModel:model];
    }
}


- (void)renderBoundsWithModel:(CEModel *)model {
    if (!model.showAccessoryLine || model.bounds.x <= 0 || model.bounds.y <= 0 || model.bounds.z <= 0) {
        return;
    }
    
    // prepare bound data for model
    GLKVector3 halfBounds = GLKVector3MultiplyScalar(model.bounds, 0.5);
    GLfloat maxX = model.offsetFromOrigin.x + halfBounds.x;
    GLfloat maxY = model.offsetFromOrigin.y + halfBounds.y;
    GLfloat maxZ = model.offsetFromOrigin.z + halfBounds.z;
    GLfloat minX = model.offsetFromOrigin.x - halfBounds.x;
    GLfloat minY = model.offsetFromOrigin.y - halfBounds.y;
    GLfloat minZ = model.offsetFromOrigin.z - halfBounds.z;
    GLfloat red = 0.5, green = 0.5, blue = 0.5, alpha = 1;
    // direction axis
    GLKVector3 axisX = model.offsetFromOrigin;
    axisX.x = maxX;
    GLKVector3 axisY = model.offsetFromOrigin;
    axisY.y = maxY;
    GLKVector3 axisZ = model.offsetFromOrigin;
    axisZ.z = maxZ;
    GLfloat vertexData[98] = { // 14 vecterx
        maxX, maxY, maxZ, red, green, blue, alpha,
        minX, maxY, maxZ, red, green, blue, alpha,
        maxX, minY, maxZ, red, green, blue, alpha,
        minX, minY, maxZ, red, green, blue, alpha,
        maxX, maxY, minZ, red, green, blue, alpha,
        minX, maxY, minZ, red, green, blue, alpha,
        maxX, minY, minZ, red, green, blue, alpha,
        minX, minY, minZ, red, green, blue, alpha,
        axisX.x - 1, axisX.y, axisX.z, 1.0, 0.0, 0.0, 1.0,
        axisX.x + 1, axisX.y, axisX.z, 1.0, 0.0, 0.0, 1.0,
        axisY.x, axisY.y - 1, axisY.z, 0.0, 1.0, 0.0, 1.0,
        axisY.x, axisY.y + 1, axisY.z, 0.0, 1.0, 0.0, 1.0,
        axisZ.x, axisZ.y, axisZ.z - 1, 0.0, 0.0, 1.0, 1.0,
        axisZ.x, axisZ.y, axisZ.z + 1, 0.0, 0.0, 1.0, 1.0
    };
    
    glGenBuffers(1, &_vertexBufferIndex);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    glVertexAttribPointer(_attributePosition, 3, GL_FLOAT, GL_FALSE, 28, CE_BUFFER_OFFSET(0));
    glVertexAttribPointer(_attributeVertexColor, 4, GL_FLOAT, GL_FALSE, 28, CE_BUFFER_OFFSET(3 * sizeof(GLfloat)));
    
    if (!_indicesBufferIndex) {
        GLbyte indicesData[30] = {
            0, 1, 0, 2, 1, 3, 3, 2,
            0, 4, 1, 5, 2, 6, 3, 7,
            4, 5, 5, 7, 7, 6, 6, 4,
            8, 9, 10, 11, 12, 13
        };
        glGenBuffers(1, &_indicesBufferIndex);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferIndex);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indicesData), indicesData, GL_STATIC_DRAW);
        
    } else {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferIndex);
    }
    
    // render
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
    projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, projectionMatrix);
    glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
    glDrawElements(GL_LINES, 30, GL_UNSIGNED_BYTE, 0);
    
    // clean up vertex buffer
    if (_vertexBufferIndex) {
        glDeleteBuffers(1, &_vertexBufferIndex);
        _vertexBufferIndex = 0;
    }
}


#pragma mark - Light
- (void)renderLights:(NSArray *)lights {
    if (!_program.initialized || !lights.count) {
        return;
    }
    
    [_program use];
    glLineWidth(2.0);
    for (CELight *light in lights) {
        CERenderObject *object = light.renderObject;
        if (!object.vertexBuffer.isReady) {
            [object.vertexBuffer setupBuffer];
        }
        if (!object.indiceBuffer.isReady) {
            [object.indiceBuffer setupBuffer];
        }
        if (![object.vertexBuffer loadBuffer] ||
            ![object.indiceBuffer loadBuffer]) {
            CEWarning(@"Fail to load buffer for rendering light object");
            [object.indiceBuffer unloadBuffer];
            [object.vertexBuffer unloadBuffer];
            continue;
        }
        
        GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.viewMatrix, light.transformMatrix);
        projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, projectionMatrix);
        glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
        
        glDrawElements(object.indiceBuffer.drawMode,
                       object.indiceBuffer.indiceCount,
                       object.indiceBuffer.primaryType, 0);
        [object.indiceBuffer unloadBuffer];
        [object.vertexBuffer unloadBuffer];
    }
}


#pragma mark - world Original Coordinate

- (void)renderWorldOriginCoordinate {
    if (!_worldOriginVertexBufferIndex) {
        GLfloat vertexData[42] = {  // Position + Color
            0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // Axis X
            1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // Axis X
            0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, // Axis Y
            0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, // Axis Y
            0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, // Axis Z
            0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f  // Axis Z
        };
        glGenBuffers(1, &_worldOriginVertexBufferIndex);
        glBindBuffer(GL_ARRAY_BUFFER, _worldOriginVertexBufferIndex);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    }
    glBindBuffer(GL_ARRAY_BUFFER, _worldOriginVertexBufferIndex);
    glEnableVertexAttribArray(_attributePosition);
    glVertexAttribPointer(_attributePosition, 3, GL_FLOAT, GL_FALSE, 28, CE_BUFFER_OFFSET(0));
    glEnableVertexAttribArray(_attributeVertexColor);
    glVertexAttribPointer(_attributeVertexColor, 4, GL_FLOAT, GL_FALSE, 28, CE_BUFFER_OFFSET(3 * sizeof(GLfloat)));
    [_program use];
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, _camera.viewMatrix);
    glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
    glLineWidth(2.0);
    glDrawArrays(GL_LINES, 0, 6);
}



@end
