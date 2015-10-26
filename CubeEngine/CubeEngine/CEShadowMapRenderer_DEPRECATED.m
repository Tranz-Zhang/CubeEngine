//
//  CEShadowMapRenderer.m
//  CubeEngine
//
//  Created by chance on 5/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowMapRenderer_DEPRECATED.h"
#import "CEMainProgram.h"
#import "CEModel_Rendering.h"

@implementation CEShadowMapRenderer_DEPRECATED {
    CEMainProgram *_program;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _program = [CEMainProgram programWithConfig:[CEProgramConfig new]];
    }
    return self;
}


- (void)renderShadowMapWithObjects:(NSArray *)objects {
    if (!_program || !objects.count) {
        return;
    }
    
    [_program beginRendering];
//    for (CEModel *model in objects) {
//        // setup vertex buffer
//        if (![model.vertexBuffer setupBuffer] ||
//            (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
//            continue;
//        }
//        CEVBOAttribute *positionAttri = [model.vertexBuffer attributeWithName:CEVBOAttributePosition];
//        if (![_program setPositionAttribute:positionAttri]){
//            continue;
//        }
//        if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
//            continue;
//        }
//        
//        GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(_lightVPMatrix, model.transformMatrix);
//        [_program setModelViewProjectionMatrix:MVPMatrix];
//        
//        if (model.indicesBuffer) { // glDrawElements
//            glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
//            
//        } else { // glDrawArrays
//            glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
//        }
//    }
    [_program endRendering];
}


@end