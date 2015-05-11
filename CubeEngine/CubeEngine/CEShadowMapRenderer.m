//
//  CEShadowMapRenderer.m
//  CubeEngine
//
//  Created by chance on 5/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowMapRenderer.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"

#import "CELight_Rendering.h"
#import "CEScene_Rendering.h"

NSString *const kShaderMapVertexShader = CE_SHADER_STRING
(
 attribute vec4 position;
 uniform mat4 projection;
 
 void main () {
     gl_Position = projection * position;
 }
 );

NSString *const kShaderMapFragmentSahder = CE_SHADER_STRING
(
 void main() {
     gl_FragColor = vec4(1.0);
 }
);


@implementation CEShadowMapRenderer {
    CEProgram *_program;
    GLint _attributePosition;
    GLint _attributeNormal;
    GLint _uniformProjection;
}


- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kShaderMapVertexShader
                                        fragmentShaderString:kShaderMapFragmentSahder];
    [_program addAttribute:@"position"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attributePosition = [_program attributeIndex:@"position"];
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


- (void)renderObjects:(NSSet *)objects {
    if (!_program || !objects.count) {
        return;
    }
    
    [_program use];
    for (CEModel *model in objects) {
        // setup vertex buffer
        if (![model.vertexBuffer setupBuffer] ||
            (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
            continue;
        }
        // prepare for rendering
        if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition
                                 withProgramIndex:_attributePosition]){
            continue;
        }
        if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
            continue;
        }
        
        GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(_lightVPMatrix, model.transformMatrix);
        glUniformMatrix4fv(_uniformProjection, 1, 0, MVPMatrix.m);
        
        if (model.indicesBuffer) { // glDrawElements
            glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
            
        } else { // glDrawArrays
            glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
        }
    }
}


@end
