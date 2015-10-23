//
//  TESTRenderer.m
//  CubeEngine
//
//  Created by chance on 10/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "TESTRenderer.h"
#import "CEDefaultProgram.h"
#import "CEShaderBuilder.h"
#import "CEModel_Rendering.h"
#import "CELight_Rendering.h"
#import "CECamera_Rendering.h"
#import "CEShadowLight_Rendering.h"
#import "CETextureManager.h"
#import "CEMainProgram.h"
#import "CEShaderInfo_setter.h"

#define ENABLE_PROGRAM_2 1

NSString *const kProgram2VertexShader = CE_SHADER_STRING
(
 attribute highp vec4 VertexPosition;
 
 uniform highp mat4 MVPMatrix;
 
 void main() {
     gl_Position = MVPMatrix * VertexPosition;
 }
 );

NSString *const kProgram2FragmentSahder = CE_SHADER_STRING
(
 precision mediump float;
 uniform vec4 DiffuseColor;
 
 void main() {
     gl_FragColor = DiffuseColor;
 }
);


@implementation TESTRenderer {
    CEProgramConfig *_config;
    CEMainProgram *_program1;
    CEDefaultProgram *_program2;
    CEShadowLight *_shadowLight;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
        [shaderBuilder startBuildingNewShader];
        [shaderBuilder setMaterialType:CEMaterialSolid];
        CEShaderInfo *shaderInfo = [shaderBuilder build];
        shaderInfo.vertexShader = kProgram2VertexShader;
        shaderInfo.fragmentShader = kProgram2FragmentSahder;
        // build program
        _program2 = [CEDefaultProgram buildProgramWithShaderInfo:shaderInfo];
        
        CEProgramConfig *config = [CEProgramConfig new];
        config.lightCount = 0;
        config.renderMode = CERenderModeSolid;
        _config = config;
        _program1 = [CEMainProgram programWithConfig:config];
    }
    return self;
}


- (void)setMainLight:(CELight *)mainLight {
    if (_mainLight != mainLight) {
        _mainLight = mainLight;
        if ([_mainLight isKindOfClass:[CEShadowLight class]]) {
            _shadowLight = (CEShadowLight *)mainLight;
        }
    }
}


- (void)renderObjects:(NSArray *)objects {
    if (!_program1 || !_camera) {
        CEError(@"Invalid renderer environment");
        return;
    }
#if ENABLE_PROGRAM_2
    [_program2 use];
    _program2.eyeDirection.vector3 = GLKVector3Make(0.0, 0.0, 1.0);
    for (CERenderObject *renderObject in objects) {
        [self test2RenderObject:renderObject];
    }
#else
    [_program1 beginRendering];
    [_program1 setEyeDirection:GLKVector3Make(0.0, 0.0, 1.0)];
    for (CERenderObject *renderObject in objects) {
        [self test1RenderObject:renderObject];
    }
    [_program1 endRendering];
#endif

    
}


- (void)test1RenderObject:(CERenderObject *)object {
    if (!object.testVertexBuffer) {
        CEError(@"Invalid render object");
        return;
    }
    
    [object.testVertexBuffer setupBuffer];
    if (![_program1 setPositionAttribute:[object.testVertexBuffer attributeWithName:CEVBOAttributePosition]]) {
        CEError(@"Fail to set position attribute");
        return;
    }
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, object.modelMatrix);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    [_program1 setModelViewProjectionMatrix:modelViewProjectionMatrix];
    
    // setup material
    static int counter = 0;
    if (counter++ % 2) {
        [_program1 setDiffuseColor:GLKVector4Make(0.5, 0.0, 0.0, 1)];
    } else {
        [_program1 setDiffuseColor:GLKVector4Make(0.0, 0.0, 0.5, 1)];
    }

    glDrawArrays(GL_TRIANGLES, 0, object.testVertexBuffer.vertexCount);
}


- (void)test2RenderObject:(CERenderObject *)object {
    if (!object.testVertexBuffer) {
        CEError(@"Invalid render object");
        return;
    }
    
    [object.testVertexBuffer setupBuffer];
    CEVBOAttribute *attribute = [object.testVertexBuffer attributeWithName:CEVBOAttributePosition];
    glEnableVertexAttribArray(CEVBOAttributePosition);
    glVertexAttribPointer(CEVBOAttributePosition,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, object.modelMatrix);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    _program2.modelViewProjectionMatrix.matrix4 = modelViewProjectionMatrix;
    
    // setup material
    static int counter = 0;
    if (counter++ % 2) {
        _program2.diffuseColor.vector4 = GLKVector4Make(0.5, 0.0, 0.0, 1);
    } else {
        _program2.diffuseColor.vector4 = GLKVector4Make(0.0, 0.0, 0.5, 1);
    }
    
    glDrawArrays(GL_TRIANGLES, 0, object.testVertexBuffer.vertexCount);
}


@end
