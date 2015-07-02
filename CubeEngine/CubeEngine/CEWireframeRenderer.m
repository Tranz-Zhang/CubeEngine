//
//  CEWireframeRenderer.m
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEWireframeRenderer.h"
#import "CEMainProgram.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

@implementation CEWireframeRenderer {
    CEMainProgram *_program;
    GLKVector4 _lineColorVec4;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _program = [CEMainProgram programWithConfig:[CEProgramConfig new]];
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


- (void)renderWireframeForObjects:(NSArray *)objects {
    if (!_program.initialized) {
        return;
    }
    [_program beginRendering];
    for (CEModel *model in objects) {
        if (!model.showWireframe || !model.wireframeBuffer) {
            continue;
        }
        // setup vertex buffer
        if (![model.wireframeBuffer setupBuffer] ||
            ![model.vertexBuffer setupBuffer]) {
            continue;
        }
        // prepare attribute for rendering
        CEVBOAttribute *positionAttri = [model.vertexBuffer attributeWithName:CEVBOAttributePosition];
        if (![_program setPositionAttribute:positionAttri]){
            continue;
        }
        glLineWidth(_lineWidth);
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
        mvpMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, mvpMatrix);
        [_program setModelViewProjectionMatrix:mvpMatrix];
        [_program setDiffuseColor:_lineColorVec4];
        glDrawElements(GL_LINES, model.wireframeBuffer.indicesCount, model.wireframeBuffer.indicesDataType, 0);
    }
    [_program endRendering];
}

 



@end


