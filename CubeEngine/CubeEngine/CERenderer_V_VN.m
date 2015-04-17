//
//  CERenderer_V_VN.m
//  CubeEngine
//
//  Created by chance on 4/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer_V_VN.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"


NSString *const kVertexShader_V_VN = CE_SHADER_STRING
(
 attribute vec4 position;
 attribute vec3 normal;

 uniform mat3 normalMatrix;
 uniform vec3 lightPosition;
 uniform vec3 diffuseMaterial;
 uniform vec3 ambientMaterial;
 uniform vec3 specularMaterial;
 uniform mat4 projection;
 uniform float shininess;
 
 varying vec4 destinationColor;
 
 void main () {
     vec3 N = normalize(normalMatrix * normal);
     vec3 L = normalize(lightPosition);
     float df = max(0.0, dot(N, L));
     
     vec3 E = vec3(0, 0, 3);
     vec3 H = normalize(L + E);
     float sf = max(0.0, dot(N, H));
     sf = pow(sf, shininess);
     
     vec3 color = ambientMaterial + df * diffuseMaterial + sf * specularMaterial;
     destinationColor = vec4(color, 1.0);
     
     gl_Position = projection * position;
 }
 );

NSString *const kFragmentSahder_V_VN = CE_SHADER_STRING
(
 varying lowp vec4 destinationColor;
 
 void main() {
     gl_FragColor = destinationColor;
 }
);


@implementation CERenderer_V_VN {
    CEProgram *_program;
    GLint _attributePosition;
    GLint _attributeNormal;
    
    GLint _uniformNormalMatrix;
    GLint _uniformLightPosition;
    GLint _uniformDiffuseMaterial;
    GLint _uniformAmbientMaterial;
    GLint _uniformSpecularMaterial;
    GLint _uniformShininess;
    GLint _uniformProjection;
}


- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kVertexShader_V_VN
                                        fragmentShaderString:kFragmentSahder_V_VN];
    [_program addAttribute:@"position"];
    [_program addAttribute:@"normal"];

    BOOL isOK = [_program link];
    if (isOK) {
        _attributePosition = [_program attributeIndex:@"position"];
        _attributeNormal = [_program attributeIndex:@"normal"];
        
        _uniformNormalMatrix = [_program uniformIndex:@"normalMatrix"];
        _uniformDiffuseMaterial = [_program uniformIndex:@"diffuseMaterial"];
        _uniformLightPosition = [_program uniformIndex:@"lightPosition"];
        _uniformAmbientMaterial = [_program uniformIndex:@"ambientMaterial"];
        _uniformSpecularMaterial = [_program uniformIndex:@"specularMaterial"];
        _uniformShininess = [_program uniformIndex:@"shininess"];
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
    if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition withProgramIndex:_attributePosition] ||
        ![model.vertexBuffer prepareAttribute:CEVBOAttributeNormal withProgramIndex:_attributeNormal]){
        return;
    }
    if (model.indicesBuffer && ![model.indicesBuffer prepareForRendering]) {
        return;
    }
    [_program use];
    
    // setup uniform values
    glUniform3f(_uniformLightPosition, 50.0f, 50.0f, 0.0f);
    glUniform3f(_uniformDiffuseMaterial, 0.8f, 0.8f, 0.8f);
    glUniform3f(_uniformAmbientMaterial, 0.04f, 0.04f, 0.04f);
    glUniform3f(_uniformSpecularMaterial, 1.0f, 1.0f, 1.0f);
    glUniform1f(_uniformShininess, 20);
    // projection matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(self.viewMatrix, model.transformMatrix);
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, modelViewMatrix);
    glUniformMatrix4fv(_uniformProjection, 1, GL_FALSE, projectionMatrix.m);
    // normal matrix
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(model.transformMatrix);
    normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
    glUniformMatrix3fv(_uniformNormalMatrix, 1, GL_FALSE, normalMatrix.m);
    
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}


@end
