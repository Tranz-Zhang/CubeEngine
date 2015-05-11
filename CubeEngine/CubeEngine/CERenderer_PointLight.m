//
//  CERenderer_PointLight.m
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer_PointLight.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

NSString *const kVertexShader_PointLight = CE_SHADER_STRING
(
 attribute highp vec4 VertexPosition;
 attribute highp vec3 VertexNormal;
 
 uniform vec4 VertexColor;
 uniform mat4 MVPMatrix;
 uniform mat4 MVMatrix;
 uniform mat3 NormalMatrix;
 
 varying vec4 Color;
 varying vec3 Normal;
 varying vec4 Position;
 
 void main () {
     Color = VertexColor;
     Normal = normalize(NormalMatrix * VertexNormal);
     Position = MVMatrix * VertexPosition;
     gl_Position = MVPMatrix * VertexPosition;
 }
 );

NSString *const kFragmentSahder_PointLight = CE_SHADER_STRING
(
 precision mediump float;
 
 uniform vec3 Ambient;
 uniform vec3 LightColor;
 // uniform vec3 LightDirection;
 // uniform vec3 HalfVector;   // surface orientation for shinest spots
 uniform float Shiniess;    // exponent for sharping highlights
 uniform float Strength;    // extra factor to adjust shiniess
 // add point light
 uniform vec3 LightPosition;
 uniform vec3 EyeDirection;
 uniform float ConstantAttenuation;
 uniform float LinearAttenuation;
 uniform float QuadraticAttenuation;
 
 varying vec4 Color;
 varying vec3 Normal;
 varying vec4 Position;
 
 void main() {
     vec3 lightDirection = LightPosition - vec3(Position);
     float lightDistance = length(lightDirection);
     
     // normalize light direction
     lightDirection = lightDirection / lightDistance;
     
     float attenuation = 1.0 / (1.0 + ConstantAttenuation * lightDistance +
                                ConstantAttenuation * lightDistance * lightDistance);
     
     // half vector
     vec3 halfVector = normalize(lightDirection + EyeDirection);
     
     float diffuse = max(0.0, dot(Normal, lightDirection));
     float specular = max(0.0, dot(Normal, halfVector));
     
     // surfaces facing away from the light (negative dot products)
     // won't be lit by the directionl light
     if (diffuse == 0.0) {
         specular = 0.0;
         
     } else {
         specular = pow(specular, Shiniess) * Strength;
     }
     
     // 这里散射光由ambient和diffuse叠加在一起，然后跟Color混合
     vec3 scatteredLight = Ambient + LightColor * diffuse * attenuation;
     // 这里的反射光，即高光，最终是直接叠加在Color上面的
     vec3 reflectedLight = LightColor * specular * attenuation;
     
     vec3 rgb = min(Color.rgb * scatteredLight + reflectedLight, vec3(1.0));
     gl_FragColor = vec4(rgb, Color.a);
 }
);


@implementation CERenderer_PointLight {
    CEProgram *_program;
    GLint _attribVec4Position;
    GLint _attribVec3Normal;
    
    GLint _uniVec4VertexColor;
    GLint _uniVec3Ambient;
    GLint _uniVec3LightColor;
    GLint _uniVec3LightLocation;
    GLint _uniVec3EyeDirection;
    
    GLint _uniFloatConstantAttenuation;
    GLint _uniFloatLinearAttenuation;
    GLint _uniFloatQuadraticAttenuation;
    
    GLint _uniFloatShiness;
    GLint _uniFloatStrength;
    
    GLint _uniMtx4MVPMatrix;
    GLint _uniMtx4MVMatrix;
    GLint _uniMtx3NormalMatrix;
}


+ (instancetype)shareRenderer {
    static CERenderer_PointLight *_shareInstance = nil;
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
        _lightLocation = GLKVector3Make(5, 5, 5);
        _shiniess = 10;
        _strength = 1.0;
        _constantAttenuation = 0.0001;
        _linearAttenuation = 0.0005;
        _quadraticAttenuation = 0.00005;
    }
    return self;
}

- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kVertexShader_PointLight
                                        fragmentShaderString:kFragmentSahder_PointLight];
    [_program addAttribute:@"VertexPosition"];
    [_program addAttribute:@"VertexNormal"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attribVec4Position     = [_program attributeIndex:@"VertexPosition"];
        _attribVec3Normal       = [_program attributeIndex:@"VertexNormal"];
        
        _uniVec4VertexColor     = [_program uniformIndex:@"VertexColor"];
        _uniVec3Ambient         = [_program uniformIndex:@"Ambient"];
        _uniVec3LightColor      = [_program uniformIndex:@"LightColor"];
        _uniVec3LightLocation   = [_program uniformIndex:@"LightPosition"];
        _uniVec3EyeDirection    = [_program uniformIndex:@"EyeDirection"];
        
        _uniFloatConstantAttenuation    = [_program uniformIndex:@"ConstantAttenuation"];
        _uniFloatLinearAttenuation      = [_program uniformIndex:@"LinearAttenuation"];
        _uniFloatQuadraticAttenuation   = [_program uniformIndex:@"QuadraticAttenuation"];
        
        _uniFloatShiness        = [_program uniformIndex:@"Shiniess"];
        _uniFloatStrength       = [_program uniformIndex:@"Strength"];
        
        _uniMtx4MVPMatrix       = [_program uniformIndex:@"MVPMatrix"];
        _uniMtx3NormalMatrix    = [_program uniformIndex:@"NormalMatrix"];
        _uniMtx4MVMatrix        = [_program uniformIndex:@"MVMatrix"];
        
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
    for (CEModel *model in objects) {
        if (!_program || !model.vertexBuffer || !_camera) {
            CEError(@"Invalid paramater for rendering");
            return;
        }
        
        // setup vertex buffer
        if (![model.vertexBuffer setupBuffer] ||
            (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
            return;
        }
        // prepare for rendering
        if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition withProgramIndex:_attribVec4Position] ||
            ![model.vertexBuffer prepareAttribute:CEVBOAttributeNormal withProgramIndex:_attribVec3Normal]){
            return;
        }
        if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
            return;
        }
        [_program use];
        
        // setup lighting uniforms
        glUniform4f(_uniVec4VertexColor, _vertexColor.r, _vertexColor.g, _vertexColor.b, _vertexColor.a);
        glUniform3f(_uniVec3Ambient, _ambientColor.r, _ambientColor.g, _ambientColor.b);
        glUniform3f(_uniVec3LightColor, _lightColor.r, _lightColor.g, _lightColor.b);
        glUniform3f(_uniVec3LightLocation, _lightLocation.x, _lightLocation.y, _lightLocation.z);
        GLKVector3 eyeDirection = GLKVector3Normalize(GLKVector3Negate(_camera.position));
        glUniform3f(_uniVec3EyeDirection, eyeDirection.x, eyeDirection.y, eyeDirection.z);
        
        glUniform1f(_uniFloatConstantAttenuation, _constantAttenuation);
        glUniform1f(_uniFloatLinearAttenuation, _linearAttenuation);
        glUniform1f(_uniFloatQuadraticAttenuation, _quadraticAttenuation);
        
        glUniform1f(_uniFloatShiness, _shiniess);
        glUniform1f(_uniFloatStrength, _strength);
        
        // setup MVP matrix
        GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
        GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
        glUniformMatrix4fv(_uniMtx4MVPMatrix, 1, GL_FALSE, projectionMatrix.m);
        glUniformMatrix4fv(_uniMtx4MVMatrix, 1, GL_FALSE, modelViewMatrix.m);
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
}


- (void)setColor:(UIColor *)color toUniform:(GLint)uniformIndex {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    glUniform4f(uniformIndex, red, green, blue, alpha);
}

@end