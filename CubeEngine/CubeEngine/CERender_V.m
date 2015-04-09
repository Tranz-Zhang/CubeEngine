//
//  CERender_V.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERender_V.h"
#import "CEProgram.h"
#import "CEMesh_Rendering.h"

NSString *const kVertexShader = CE_SHADER_STRING
(
 attribute highp vec4 position;
 uniform mat4 projection;
 
 void main () {
     gl_Position = projection * position;
 }
 );

NSString *const kFragmentSahder = CE_SHADER_STRING
(
 void main() {
     gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
 }
);


@implementation CERender_V {
    CEProgram *_program;
    GLint _attributePosition;
    GLint _uniformProjection;
}


- (BOOL)prepareRender {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kVertexShader
                                        fragmentShaderString:kFragmentSahder];
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
    }
    
    return isOK;
}


- (void)renderModel:(CEModel *)model {
    if (!_program || !model.mesh) return;
    CEMesh *mesh = model.mesh;
    BOOL prepared = [mesh prepareDrawingWithPositionIndex:_attributePosition
                                        textureCoordIndex:-1
                                              normalIndex:-1];
    if (prepared) {
        // setup camera projection
        GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(self.cameraProjectionMatrix, model.transformMatrix);
        glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
        
        [_program use];
        GLenum indicesType = (mesh.indicesDataType == CEIndicesDataType_UByte ? GL_UNSIGNED_BYTE : GL_UNSIGNED_SHORT);
        glDrawElements(GL_TRIANGLES, mesh.indicesCount, indicesType, 0);
    }
}


@end
