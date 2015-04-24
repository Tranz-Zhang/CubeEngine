//
//  CERenderer_DirectionalLight.m
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer_DirectionalLight.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"


NSString *const kVertexShader_DirectionalLight = CE_SHADER_STRING
(
 attribute highp vec4 VertexPosition;
 attribute highp vec3 VertexNormal;
 
 uniform mat4 MVPMatrix;
 uniform mat3 NormalMatrix;
 uniform vec4 VertexColor;
 
 varying vec4 Color;
 varying vec3 Normal;
 varying vec4 Position;
 
 void main () {
     Color = VertexColor;
     Position = normalize(VertexPosition);
     Normal = normalize(NormalMatrix * VertexNormal);
     gl_Position = MVPMatrix * VertexPosition;
 }
);

NSString *const kFragmentSahder_DirectionalLight = CE_SHADER_STRING
(
 precision mediump float;
 
 struct TestInfo {
     vec3 RenderColor;
     float Range;
 };
 uniform TestInfo test[2];
 
 uniform vec3 Ambient;
 uniform vec3 LightColor;
 uniform vec3 LightDirection;
 uniform vec3 HalfVector;   // surface orientation for shinest spots
 uniform float Shiniess;    // exponent for sharping highlights
 uniform float Strength;    // extra factor to adjust shiniess
 
 varying vec4 Color;
 varying vec3 Normal;
 varying vec4 Position;
 
 void main() {
     vec4 finalColor;
     if (Position.y > test[0].Range) {
         finalColor = vec4(test[0].RenderColor, 1.0);
     } else {
         finalColor = vec4(test[1].RenderColor, 0.0);
     }
     
     float diffuse = max(0.0, dot(Normal, LightDirection));
     float specular = max(0.0, dot(Normal, HalfVector));
     
     // surfaces facing away from the light (negative dot products)
     // won't be lit by the directionl light
     if (diffuse == 0.0) {
         specular = 0.0;
         
     } else {
         specular = pow(specular, Shiniess);
     }
     
     // 这里散射光由ambient和diffuse叠加在一起，然后跟Color混合
     vec3 scatteredLight = Ambient + LightColor * diffuse;
     // 这里的反射光，即高光，最终是直接叠加在Color上面的
     vec3 reflectedLight = LightColor * specular * Strength;
     
     vec3 rgb = min(finalColor.rgb * scatteredLight + reflectedLight, vec3(1.0));
     gl_FragColor = vec4(rgb, finalColor.a);
 }
 );


@implementation CERenderer_DirectionalLight {
    CEProgram *_program;
    GLint _attribVec4Position;
    GLint _attribVec3Normal;
    
    GLint _uniVec4VertexColor;
    GLint _uniVec3Ambient;
    GLint _uniVec3LightColor;
    GLint _uniVec3LightDirection;
    GLint _uniVec3HalfVector;
    GLint _uniFloatShiness;
    GLint _uniFloatStrength;
    
    GLint _uniMtx4MVPMatrix;
    GLint _uniMtx3NormalMatrix;
    
    GLint _test0_RenderColor;
    GLint _test0_Range;
    GLint _test1_RenderColor;
    GLint _test1_Range;
}


+ (instancetype)shareRenderer {
    static CERenderer_DirectionalLight *_shareInstance = nil;
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[[self class] alloc] init];
        });
    }
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _vertexColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
        _ambientColor = GLKVector3Make(0.1, 0.1, 0.1);
        _lightColor = GLKVector3Make(1.0, 1.0, 1.0);
        [self setLightDirection:GLKVector3Make(1.0, 1.0, 1.0)];
        _shiniess = 10;
        _strength = 0.1;
    }
    return self;
}

- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kVertexShader_DirectionalLight
                                        fragmentShaderString:kFragmentSahder_DirectionalLight];
    [_program addAttribute:@"VertexPosition"];
    [_program addAttribute:@"VertexNormal"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attribVec4Position     = [_program attributeIndex:@"VertexPosition"];
        _attribVec3Normal       = [_program attributeIndex:@"VertexNormal"];
        
        _uniVec4VertexColor     = [_program uniformIndex:@"VertexColor"];
        _uniVec3Ambient         = [_program uniformIndex:@"Ambient"];
        _uniVec3LightColor      = [_program uniformIndex:@"LightColor"];
        _uniVec3LightDirection  = [_program uniformIndex:@"LightDirection"];
        _uniVec3HalfVector      = [_program uniformIndex:@"HalfVector"];
        _uniFloatShiness        = [_program uniformIndex:@"Shiniess"];
        _uniFloatStrength       = [_program uniformIndex:@"Strength"];
        
        _uniMtx4MVPMatrix       = [_program uniformIndex:@"MVPMatrix"];
        _uniMtx3NormalMatrix    = [_program uniformIndex:@"NormalMatrix"];
        
        _test0_RenderColor = [_program uniformIndex:@"test[0].RenderColor"];
        _test0_Range = [_program uniformIndex:@"test[0].Range"];
        _test1_RenderColor = [_program uniformIndex:@"test[1].RenderColor"];
        _test1_Range = [_program uniformIndex:@"test[1].Range"];
        
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

- (void)setLightDirection:(GLKVector3)lightDirection {
    _lightDirection = GLKVector3Normalize(lightDirection);
    GLKVector3 eyeDirection = GLKVector3Normalize(GLKVector3Negate(_camera.position));
    _halfVector = GLKVector3Normalize(GLKVector3Add(lightDirection, eyeDirection));
}


- (void)renderObject:(CEModel *)model {
    if (!_program || !model.vertexBuffer || !_camera) {
        CEError(@"Invalid paramater for rendering");
        return;
    }
    
    // setup vertex buffer
    if (![model.vertexBuffer setupBufferWithContext:self.context] ||
        (model.indicesBuffer && ![model.indicesBuffer setupBufferWithContext:self.context])) {
        return;
    }
    // prepare for rendering
    if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition withProgramIndex:_attribVec4Position] ||
        ![model.vertexBuffer prepareAttribute:CEVBOAttributeNormal withProgramIndex:_attribVec3Normal]){
        return;
    }
    if (model.indicesBuffer && ![model.indicesBuffer prepareForRendering]) {
        return;
    }
    [_program use];
    
    // setup lighting uniforms
    glUniform4f(_uniVec4VertexColor, _vertexColor.r, _vertexColor.g, _vertexColor.b, _vertexColor.a);
    glUniform3f(_uniVec3Ambient, _ambientColor.r, _ambientColor.g, _ambientColor.b);
    glUniform3f(_uniVec3LightColor, _lightColor.r, _lightColor.g, _lightColor.b);
    glUniform3f(_uniVec3LightDirection, _lightDirection.x, _lightDirection.y, _lightDirection.z);
    glUniform3f(_uniVec3HalfVector, _halfVector.x, _halfVector.y, _halfVector.z);
    glUniform1f(_uniFloatShiness, _shiniess);
    glUniform1f(_uniFloatStrength, _strength);
    
    // test uniform
    glUniform3f(_test0_RenderColor, 1.0, 0.0, 0.0);
    glUniform1f(_test0_Range, 0.2);
    glUniform3f(_test1_RenderColor, 0.0, 0.0, 1.0);
    glUniform1f(_test1_Range, 0.0);
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    glUniformMatrix4fv(_uniMtx4MVPMatrix, 1, GL_FALSE, projectionMatrix.m);
    // setup normal matrix
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
    normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
    glUniformMatrix3fv(_uniMtx3NormalMatrix, 1, GL_FALSE, normalMatrix.m);
    
    
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}


- (void)setColor:(UIColor *)color toUniform:(GLint)uniformIndex {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    glUniform4f(uniformIndex, red, green, blue, alpha);
}

@end
