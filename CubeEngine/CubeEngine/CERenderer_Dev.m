//
//  CERenderer_Dev.m
//  CubeEngine
//
//  Created by chance on 4/17/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer_Dev.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"


NSString *const kVertexShader_DEV = CE_SHADER_STRING
(
 attribute highp vec4 VertexPosition;
 attribute highp vec3 VertexNormal;
 
 uniform mat4 MVPMatrix;
 uniform mat3 NormalMatrix;
 uniform vec4 VertexColor;
 
 varying vec4 Color;
 varying vec3 Normal;
 
 void main () {
     Color = VertexColor;
     Normal = normalize(NormalMatrix * VertexNormal);
     gl_Position = MVPMatrix * VertexPosition;
 }
);

NSString *const kFragmentSahder_DEV = CE_SHADER_STRING
(
 precision mediump float;
 
 uniform vec3 Ambient;
 uniform vec3 LightColor;
 uniform vec3 LightDirection;
 uniform vec3 HalfVector;   // surface orientation for shinest spots
 uniform float Shiniess;    // exponent for sharping highlights
 uniform float Strength;    // extra factor to adjust shiniess
 
 varying vec4 Color;
 varying vec3 Normal;
 
 void main() {
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
     
     vec3 rgb = min(Color.rgb * scatteredLight + reflectedLight, vec3(1.0));
     gl_FragColor = vec4(rgb, Color.a);
 }
);


@implementation CERenderer_Dev {
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
}


+ (instancetype)shareRenderer {
    static CERenderer_Dev *_shareInstance = nil;
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
        [self setHalfVector:GLKVector3Make(1.0, 1.0, 1.0)];
        _shiniess = 10;
        _strength = 1.0;
    }
    return self;
}

- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kVertexShader_DEV
                                        fragmentShaderString:kFragmentSahder_DEV];
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

- (void)setLightDirection:(GLKVector3)lightDirection {
    _lightDirection = GLKVector3Normalize(lightDirection);
    GLKVector3 eyeDirection = GLKVector3Normalize(_camera.position);
    _halfVector = GLKVector3Normalize(GLKVector3Add(lightDirection, eyeDirection));
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
        glUniform3f(_uniVec3LightDirection, _lightDirection.x, _lightDirection.y, _lightDirection.z);
        glUniform3f(_uniVec3HalfVector, _halfVector.x, _halfVector.y, _halfVector.z);
        glUniform1f(_uniFloatShiness, _shiniess);
        glUniform1f(_uniFloatStrength, _strength);
        
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
}


- (void)setColor:(UIColor *)color toUniform:(GLint)uniformIndex {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    glUniform4f(uniformIndex, red, green, blue, alpha);
}

@end
