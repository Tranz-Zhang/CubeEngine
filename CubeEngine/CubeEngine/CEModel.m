//
//  CEModel.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModel.h"
#import "CEModel_Rendering.h"
#import "CEObjFileLoader.h"

@implementation CEModel {
    
}

+ (CEModel *)modelWithObjFile:(NSString *)objFileName {
    CEObjFileLoader *fileLoader =  [CEObjFileLoader new];
    return [fileLoader loadModelWithObjFileName:objFileName];
}

- (instancetype)initWithVertexBuffer:(CEVertexBuffer *)vertexBuffer
                       indicesBuffer:(CEIndicesBuffer *)indicesBuffer
{
    self = [super init];
    if (self) {
        _vertexBuffer = vertexBuffer;
        _indicesBuffer = indicesBuffer;
    }
    return self;
}


#pragma mark - Wireframe
- (void)setShowWireframe:(BOOL)showWireframe {
    if (showWireframe != _showWireframe) {
        _showWireframe = showWireframe;
        if (showWireframe && !_wireframeBuffer) {
            // 性能上考虑，这里即使取消显示线框，线框的索引数据依然会保存直到mesh销毁
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            [self parseWireframeIndices];
            CEPrintf("parseWireframeIndices duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
        }
    }
}

- (void)parseWireframeIndices {
    if (_vertexBuffer.vertexData && _vertexBuffer.vertexCount &&
        _vertexBuffer.vertexCount % 3 != 0) {
        return;
    }
    CEVBOAttribute *positionAttribute = [_vertexBuffer attributeWithName:CEVBOAttributePosition];
    if (!positionAttribute) {
        return;
    }
    
    NSMutableData *lineIndicesData = [NSMutableData data];
    unsigned int indicesCount = 0;
    NSMutableSet *insertedLineSet = [NSMutableSet set];
    NSRange readRange = NSMakeRange([_vertexBuffer offsetOfAttribute:CEVBOAttributePosition] / sizeof(Byte),
                                    positionAttribute.dataSize * positionAttribute.dataCount);
    for (int i = 0; i < _vertexBuffer.vertexCount; i += 3) {
        GLfloat points[3][3] = {0};
        for (int j = 0; j < 3; j++) {
            [_vertexBuffer.vertexData getBytes:points[j] range:readRange];
            readRange.location += _vertexBuffer.vertexStride;
        }
        
        // change to line indices
        for (int j = 0; j < 3; j++) {
            GLfloat *p0 = points[j];
            GLfloat *p1 = points[(j + 1) % 3];
            id lineId = [self generateLineIdWithBetweenPoint:p0 andPoint:p1];
            if (![insertedLineSet containsObject:lineId]) {
                GLuint index0 = i + j;
                GLuint index1 = i + (j + 1) % 3;
                [lineIndicesData appendBytes:&index0 length:sizeof(GLuint)];
                [lineIndicesData appendBytes:&index1 length:sizeof(GLuint)];
                [insertedLineSet addObject:lineId];
                indicesCount += 2;
            }
        }
    }
    
    _wireframeBuffer = [[CEIndicesBuffer alloc] initWithData:lineIndicesData
                                                indicesCount:indicesCount];
}


- (id)generateLineIdWithBetweenPoint:(GLfloat *)p0 andPoint:(GLfloat *)p1 {
    NSMutableData *identifierData = [NSMutableData dataWithCapacity:24];
    int compareResult = p0[0] - p1[0];
    if (0 == compareResult) {
        compareResult = p0[1] - p1[1];
    }
    if (0 == compareResult) {
        compareResult = p0[2] - p1[2];
    }
    
    if (compareResult > 0) {
        [identifierData appendBytes:p0 length:12];
        [identifierData appendBytes:p1 length:12];
        
    } else {
        [identifierData appendBytes:p1 length:12];
        [identifierData appendBytes:p0 length:12];
    }
    
//    NSMutableData *identifierData = [NSMutableData dataWithCapacity:24];
//    if (diffSum >= 0) {
//        [identifierData appendBytes:p0 length:12];
//        [identifierData appendBytes:p1 length:12];
//        
//    } else {
//        [identifierData appendBytes:p1 length:12];
//        [identifierData appendBytes:p0 length:12];
//    }
    return identifierData;
}


- (void)testAutoGenerateIndicesBuffer {
    
}


@end
