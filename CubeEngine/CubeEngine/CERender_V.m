//
//  CERender_V.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERender_V.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"


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


- (BOOL)setupRenderer {
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


- (void)renderObject:(CEModel *)model {
    if (!_program || !model.vertexBuffer) return;
    
    // setup vertex buffer
    if (![model.vertexBuffer setupBufferWithContext:self.context] ||
        (model.indicesBuffer && [model.indicesBuffer setupBufferWithContext:self.context])) {
        return;
    }
    // prepare for rendering
    if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition
                            withProgramIndex:_attributePosition]){
        return;
    }
    if (model.indicesBuffer && ![model.indicesBuffer prepareForRendering]) {
        return;
    }
    [_program use];
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(self.cameraProjectionMatrix, model.transformMatrix);
    glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
    
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
//
//    if (prepared) {
//        [_program use]; // must call before setting uniform?
//        // setup camera projection
//        GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(self.cameraProjectionMatrix, model.transformMatrix);
//        glUniformMatrix4fv(_uniformProjection, 1, 0, projectionMatrix.m);
//        
//        if (model.indicesBuffer) { // glDrawElements
//            
//            
//        } else { // glDrawArrays
//            glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
//        }
//        
////        GLenum indicesType = (mesh.indicesDataType == CEIndicesDataTypeU8 ? GL_UNSIGNED_BYTE : GL_UNSIGNED_SHORT);
////        glDrawElements(GL_TRIANGLES, mesh.indicesCount, indicesType, 0);
//        
//        GLsizei vertexCount = (GLsizei)mesh.vertexData.length / mesh.vertexStride;
//        glDrawArrays(GL_TRIANGLES, 0, vertexCount);
//        
////        glLineWidth(2.0);
////        glDrawElements(GL_LINE_LOOP, mesh.indicesCount, indicesType, 0);
//    }
}


@end
