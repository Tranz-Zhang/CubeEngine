//
//  CEWireframeRenderer.m
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEWireframeRenderer.h"
#import "CEMesh_Wireframe.h"
#import "CEMesh_Rendering.h"
#import "CEProgram.h"

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
    }
    
    return isOK;
}


- (void)renderObject:(CEModel *)model {
    if (!_program || !model.mesh) return;
    CEMesh *mesh = model.mesh;
    BOOL prepared = [mesh prepareWireframeDrawingWithPositionIndex:_attributePosition];
    if (prepared) {
        [_program use];
        // setup camera projection
        GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(self.cameraProjectionMatrix, model.transformMatrix);
        glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
        glUniform4f(_uniformDrawColor, 0.0, 0.0, 0.0, 1.0);
        GLenum indicesType = (mesh.wireframeIndicesDataType == CEIndicesDataTypeU8 ? GL_UNSIGNED_BYTE : GL_UNSIGNED_SHORT);
        glDrawElements(GL_LINES, mesh.wireframeIndicesCount, indicesType, 0);
    }
}


@end
