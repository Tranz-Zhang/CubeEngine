//
//  CEWireframeRenderer.m
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEWireframeRenderer.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"
#import "CEIndiceBuffer.h"
#import "CEVBOAttribute.h"

@interface CEIndiceBuffer (DataSource)

- (NSData *)indiceData;

@end

@implementation CEIndiceBuffer (DataSource)

- (NSData *)indiceData {
    return _indiceData;
}

@end


NSString *const kWireframeVertexShader = CE_SHADER_STRING
(
 attribute lowp vec4 position;
 uniform mat4 projection;

 void main () {
     gl_Position = projection * position;
 }
);

NSString *const kWireframeFragmentSahder = CE_SHADER_STRING
(
 uniform lowp vec4 lineColor;
 void main() {
     gl_FragColor = lineColor;
 }
);

@implementation CEWireframeRenderer {
    CEProgram *_program;
    GLint _attributePosition;
    GLint _uniformProjection;
    GLint _uniformLineColor;
    
    NSMutableDictionary *_indiceBufferDict; // @{CEIndiceBuffer : @(&CERenderObject)}
    
    GLKVector4 _lineColorVec4;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _lineWidth = 2.0f;
        [self setLineColor:[UIColor colorWithRed:0.259 green:1.0 blue:0.64 alpha:1]];
        [self setupRenderer];
        _indiceBufferDict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kWireframeVertexShader
                                        fragmentShaderString:kWireframeFragmentSahder];
    [_program addAttribute:@"position" atIndex:CEVBOAttributePosition];
    BOOL isOK = [_program link];
    if (isOK) {
        _attributePosition = [_program attributeIndex:@"position"];
        _uniformProjection = [_program uniformIndex:@"projection"];
        _uniformLineColor = [_program uniformIndex:@"lineColor"];
        
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


- (void)setLineColor:(UIColor *)lineColor {
    if (_lineColor != lineColor) {
        _lineColor = [lineColor copy];
        CGFloat red, green, blue, alpha;
        [lineColor getRed:&red green:&green blue:&blue alpha:&alpha];
        _lineColorVec4 = GLKVector4Make(red, green, blue, alpha);
    }
}


- (void)renderWireframeForModels:(NSArray *)models {
    if (!_program.initialized) {
        return;
    }
    [_program use];
    glUniform4fv(_uniformLineColor, 1, _lineColorVec4.v);
    glLineWidth(_lineWidth);
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, _camera.viewMatrix);
    for (CEModel *model in models) {
        if (!model.showWireframe) continue;
        GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(model.position.x, model.position.y, model.position.z);
        tranformMatrix = GLKMatrix4Multiply(tranformMatrix, GLKMatrix4MakeWithQuaternion(model.rotation));
        tranformMatrix = GLKMatrix4ScaleWithVector3(tranformMatrix, GLKVector3MultiplyScalar(model.scale, 1.002));
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(projectionMatrix, tranformMatrix);
        glUniformMatrix4fv(_uniformProjection, 1, 0, mvpMatrix.m);
        
        for (CERenderObject *object in model.renderObjects) {
            if (!object.vertexBuffer) return;
            
            CEIndiceBuffer *wireframeIndiceBuffer = [self wireframeIndiceBufferForObject:object];
            if (!wireframeIndiceBuffer) return;
            
            if (![object.vertexBuffer loadBuffer] || ![wireframeIndiceBuffer loadBuffer]) {
                CEError(@"WireframeRenderer: Render object fail to load buffer");
                [object.indiceBuffer unloadBuffer];
                [object.vertexBuffer unloadBuffer];
                return;
            }
            glDrawElements(wireframeIndiceBuffer.drawMode,
                           wireframeIndiceBuffer.indiceCount,
                           wireframeIndiceBuffer.primaryType, 0);
            [wireframeIndiceBuffer unloadBuffer];
            [object.vertexBuffer unloadBuffer];
        }
    }
}


- (CEIndiceBuffer *)wireframeIndiceBufferForObject:(CERenderObject *)object {
    NSString *bufferID = [NSString stringWithFormat:@"%p", object];
    CEIndiceBuffer *buffer = _indiceBufferDict[bufferID];
    if (buffer) {
        return buffer;
    }
    // generate wireframe indice buffer
    NSData *sourceData = object.indiceBuffer.indiceData;
    NSMutableData *indiceData = [NSMutableData data];
    size_t indiceCount = 0;
    if (object.indiceBuffer.drawMode == GL_TRIANGLES) {
        if (object.indiceBuffer.indiceCount % 3 != 0) {
            return nil;
        }
        if (object.indiceBuffer.primaryType == GL_UNSIGNED_SHORT) {
            for (int i = 0; i < object.indiceBuffer.indiceCount; i += 3) {
                unsigned short idx0, idx1, idx2;
                [sourceData getBytes:&idx0 range:NSMakeRange(i * sizeof(uint16_t), sizeof(uint16_t))];
                [sourceData getBytes:&idx1 range:NSMakeRange((i + 1) * sizeof(uint16_t), sizeof(uint16_t))];
                [sourceData getBytes:&idx2 range:NSMakeRange((i + 2) * sizeof(uint16_t), sizeof(uint16_t))];
                [indiceData appendBytes:&idx0 length:sizeof(uint16_t)];
                [indiceData appendBytes:&idx1 length:sizeof(uint16_t)];
                [indiceData appendBytes:&idx0 length:sizeof(uint16_t)];
                [indiceData appendBytes:&idx2 length:sizeof(uint16_t)];
                [indiceData appendBytes:&idx1 length:sizeof(uint16_t)];
                [indiceData appendBytes:&idx2 length:sizeof(uint16_t)];
                indiceCount += 6;
            }
            buffer = [[CEIndiceBuffer alloc] initWithData:indiceData.copy
                                              indiceCount:(uint32_t)indiceCount
                                              primaryType:GL_UNSIGNED_SHORT
                                                 drawMode:GL_LINES];
            
        } else if (object.indiceBuffer.primaryType == GL_UNSIGNED_BYTE) {
            for (int i = 0; i < object.indiceBuffer.indiceCount; i += 3) {
                unsigned char idx0, idx1, idx2;
                [sourceData getBytes:&idx0 range:NSMakeRange(i * sizeof(uint8_t), sizeof(uint8_t))];
                [sourceData getBytes:&idx1 range:NSMakeRange((i + 1) * sizeof(uint8_t), sizeof(uint8_t))];
                [sourceData getBytes:&idx2 range:NSMakeRange((i + 2) * sizeof(uint8_t), sizeof(uint8_t))];
                [indiceData appendBytes:&idx0 length:sizeof(uint8_t)];
                [indiceData appendBytes:&idx1 length:sizeof(uint8_t)];
                [indiceData appendBytes:&idx0 length:sizeof(uint8_t)];
                [indiceData appendBytes:&idx2 length:sizeof(uint8_t)];
                [indiceData appendBytes:&idx1 length:sizeof(uint8_t)];
                [indiceData appendBytes:&idx2 length:sizeof(uint8_t)];
                indiceCount += 6;
            }
            buffer = [[CEIndiceBuffer alloc] initWithData:indiceData.copy
                                              indiceCount:(uint32_t)indiceCount
                                              primaryType:GL_UNSIGNED_BYTE
                                                 drawMode:GL_LINES];
        }
        
    } else if (object.indiceBuffer.drawMode == GL_TRIANGLE_STRIP) {
        if (object.indiceBuffer.primaryType == GL_UNSIGNED_SHORT) {
            unsigned short idx0, idx1, idx2;
            [sourceData getBytes:&idx0 range:NSMakeRange(0, sizeof(uint16_t))];
            [sourceData getBytes:&idx1 range:NSMakeRange(sizeof(uint16_t), sizeof(uint16_t))];
            for (int i = 2; i < object.indiceBuffer.indiceCount; i++) {
                [sourceData getBytes:&idx2 range:NSMakeRange(i * sizeof(uint16_t), sizeof(uint16_t))];
                if (idx0 != idx1 && idx0 != idx2 && idx1 != idx2) {
                    [indiceData appendBytes:&idx0 length:sizeof(uint16_t)];
                    [indiceData appendBytes:&idx1 length:sizeof(uint16_t)];
                    [indiceData appendBytes:&idx0 length:sizeof(uint16_t)];
                    [indiceData appendBytes:&idx2 length:sizeof(uint16_t)];
                    [indiceData appendBytes:&idx1 length:sizeof(uint16_t)];
                    [indiceData appendBytes:&idx2 length:sizeof(uint16_t)];
                    indiceCount += 6;
                }
                idx0 = idx1;
                idx1 = idx2;
            }
            buffer = [[CEIndiceBuffer alloc] initWithData:indiceData.copy
                                              indiceCount:(uint32_t)indiceCount
                                              primaryType:GL_UNSIGNED_SHORT
                                                 drawMode:GL_LINES];
            
        } else if (object.indiceBuffer.primaryType == GL_UNSIGNED_BYTE) {
            unsigned char idx0, idx1, idx2;
            [sourceData getBytes:&idx0 range:NSMakeRange(0, sizeof(uint8_t))];
            [sourceData getBytes:&idx1 range:NSMakeRange(sizeof(uint8_t), sizeof(uint8_t))];
            for (int i = 2; i < object.indiceBuffer.indiceCount; i++) {
                [sourceData getBytes:&idx2 range:NSMakeRange(i * sizeof(uint8_t), sizeof(uint8_t))];
                if (idx0 != idx1 && idx0 != idx2 && idx1 != idx2) {
                    [indiceData appendBytes:&idx0 length:sizeof(uint8_t)];
                    [indiceData appendBytes:&idx1 length:sizeof(uint8_t)];
                    [indiceData appendBytes:&idx0 length:sizeof(uint8_t)];
                    [indiceData appendBytes:&idx2 length:sizeof(uint8_t)];
                    [indiceData appendBytes:&idx1 length:sizeof(uint8_t)];
                    [indiceData appendBytes:&idx2 length:sizeof(uint8_t)];
                    indiceCount += 6;
                }
                idx0 = idx1;
                idx1 = idx2;
            }
            buffer = [[CEIndiceBuffer alloc] initWithData:indiceData.copy
                                              indiceCount:(uint32_t)indiceCount
                                              primaryType:GL_UNSIGNED_BYTE
                                                 drawMode:GL_LINES];
        }
    }
    
    if (buffer) {
        [buffer setupBuffer];
        _indiceBufferDict[bufferID] = buffer;
    }
    return buffer;
}


@end


