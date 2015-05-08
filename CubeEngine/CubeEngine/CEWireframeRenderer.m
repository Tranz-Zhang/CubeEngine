//
//  CEWireframeRenderer.m
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEWireframeRenderer.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

NSString *const kWireframeVertexShader = CE_SHADER_STRING
(
 attribute highp vec4 position;
 uniform mat4 projection;
 
 void main () {
     gl_Position = projection * position;
 }
 );

NSString *const kWireframeFragmentSahder = CE_SHADER_STRING
(
 uniform lowp vec4 drawColor;
 void main() {
     gl_FragColor = drawColor;
 }
);



@implementation CEWireframeRenderer {
    CEProgram *_program;
    GLint _attributePosition;
    GLint _uniformProjection;
    GLint _uniformDrawColor;
    GLKVector4 _lineColorVec4;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineWidth = 2.0f;
        [self setLineColor:[UIColor colorWithWhite:0.2 alpha:1.0f]];
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor {
    if (_lineColor != lineColor) {
        _lineColor = [lineColor copy];
        CGFloat red, green, blue, alpha;
        [lineColor getRed:&red green:&green blue:&blue alpha:&alpha];
        _lineColorVec4 = GLKVector4Make(red, green, blue, alpha);
    }
}

- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kWireframeVertexShader
                                        fragmentShaderString:kWireframeFragmentSahder];
    [_program addAttribute:@"position"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attributePosition = [_program attributeIndex:@"position"];
        _uniformProjection = [_program uniformIndex:@"projection"];
        _uniformDrawColor = [_program uniformIndex:@"drawColor"];
        
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


- (void)renderObject:(CEModel *)model {
    if (!_program.initialized) {
        return;
    }
    // setup vertex buffer
    if (![model.wireframeBuffer setupBuffer] ||
        ![model.vertexBuffer setupBuffer]) {
        return;
    }
    // prepare attribute for rendering
    if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition withProgramIndex:_attributePosition] ||
        ![model.wireframeBuffer bindBuffer]){
        return;
    }
    [_program use];
    glLineWidth(_lineWidth);
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
    projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, projectionMatrix);
    glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
    glUniform4f(_uniformDrawColor, _lineColorVec4.r, _lineColorVec4.g, _lineColorVec4.b, _lineColorVec4.a);
    glDrawElements(GL_LINES, model.wireframeBuffer.indicesCount, model.wireframeBuffer.indicesDataType, 0);
}


@end
