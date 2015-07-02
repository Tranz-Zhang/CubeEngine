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
#import "CEUtils.h"

@implementation CEModel {
    
}

+ (CEModel *)modelWithObjFile:(NSString *)objFileName {
    CEObjFileLoader *fileLoader =  [CEObjFileLoader new];
    return [[fileLoader loadModelWithObjFileName:objFileName] anyObject];
}

- (instancetype)initWithVertexBuffer:(CEVertexBuffer *)vertexBuffer
                       indicesBuffer:(CEIndicesBuffer *)indicesBuffer {
    self = [super init];
    if (self) {
        _vertexBuffer = vertexBuffer;
        _indicesBuffer = indicesBuffer;
        [self setupMeshWithVertexBuffer:vertexBuffer];
        [self setBaseColor:[UIColor whiteColor]];
    }
    return self;
}


- (void)dealloc {
    if (_texture) {
        GLuint name = _texture.name;
        glDeleteTextures(1, &name);
        _texture = nil;
    }
}


- (void)setupMeshWithVertexBuffer:(CEVertexBuffer *)vertexBuffer {
    // vertex info
    CEVBOAttribute *positionInfo = [vertexBuffer attributeWithName:CEVBOAttributePosition];
    if (!positionInfo) {
        CEError(@"Fail to parse mess info");
        return;
    }

    // calculate model size
    NSRange readRange = NSMakeRange(positionInfo.elementOffset,
                                    positionInfo.primaryCount * positionInfo.primarySize);
    GLfloat maxX = FLT_MIN, maxY = FLT_MIN, maxZ = FLT_MIN;
    GLfloat minX = FLT_MAX, minY = FLT_MAX, minZ = FLT_MAX;
    for (int i = 0; i < vertexBuffer.vertexCount; i++) {
        GLfloat vertexLocation[3];
        [vertexBuffer.vertexData getBytes:vertexLocation range:readRange];
        maxX = MAX(maxX, vertexLocation[0]);
        maxY = MAX(maxY, vertexLocation[1]);
        maxZ = MAX(maxZ, vertexLocation[2]);
        minX = MIN(minX, vertexLocation[0]);
        minY = MIN(minY, vertexLocation[1]);
        minZ = MIN(minZ, vertexLocation[2]);
        readRange.location += vertexBuffer.vertexStride;
    }
    
    // original offset
    _offsetFromOrigin = GLKVector3Make((maxX + minX) / 2,
                                       (maxY + minY) / 2,
                                       (maxZ + minZ) / 2);
    _bounds = GLKVector3Make(maxX - minX, maxY - minY, maxZ - minZ);
}


- (NSString *)debugDescription {
    return _name;
}

#pragma mark - Setters & Getters

- (void)setBaseColor:(UIColor *)baseColor {
    _material.diffuseColor = CEVec3WithColor(baseColor);
}

- (UIColor *)baseColor {
    return _material ? CEColorWithVec3(_material.diffuseColor) : nil;
}


#pragma mark - API

- (CEModel *)childWithName:(NSString *)modelName {
    for (CEModel *child in _childObjects) {
        if ([child.name isEqualToString:modelName]) {
            return child;
        }
    }
    // search child's child
    for (CEModel *child in _childObjects) {
        CEModel *childChild = [child childWithName:modelName];
        if (childChild) {
            return childChild;
        }
    }
    return nil;
}


- (CEModel *)duplicate {
    CEModel *duplicatedModel = [CEModel new];
    [duplicatedModel setupDuplicatedModelWithVertexBuffer:_vertexBuffer
                                            indicesBuffer:_indicesBuffer
                                          wireframeBuffer:_wireframeBuffer
                                                   bounds:_bounds
                                         offsetFromOrigin:_offsetFromOrigin];
    duplicatedModel.name = _name;
    duplicatedModel.position = _position;
    duplicatedModel.rotation = _rotation;
    duplicatedModel.scale = _scale;
    duplicatedModel.castShadows = _castShadows;
    duplicatedModel.showAccessoryLine = _showAccessoryLine;
    duplicatedModel.showWireframe = _showWireframe;
    
    return duplicatedModel;
}


// duplicated ivars which can't accessed outside.
- (void)setupDuplicatedModelWithVertexBuffer:(CEVertexBuffer *)vertexBuffer
                               indicesBuffer:(CEIndicesBuffer *)indicesBuffer
                             wireframeBuffer:(CEIndicesBuffer *)wireframeBuffer
                                      bounds:(GLKVector3)bounds
                            offsetFromOrigin:(GLKVector3)offsetFromOrigin {
    _vertexBuffer = vertexBuffer;
    _indicesBuffer = indicesBuffer;
    _wireframeBuffer = wireframeBuffer;
    _bounds = bounds;
    _offsetFromOrigin = offsetFromOrigin;
}


#pragma mark - Wireframe
- (void)setShowAccessoryLine:(BOOL)showAccessoryLine {
    _showAccessoryLine = showAccessoryLine;
    for (CEModel *child in _childObjects) {
        child.showAccessoryLine = showAccessoryLine;
    }
}


- (void)setShowWireframe:(BOOL)showWireframe {
#warning Some Bug when the model is a 4-point plant
    if (showWireframe != _showWireframe) {
        _showWireframe = showWireframe;
        if (showWireframe && !_wireframeBuffer) {
            // 性能上考虑，这里即使取消显示线框，线框的索引数据依然会保存直到mesh销毁
//            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            [self parseWireframeIndices];
//            CEPrintf("parseWireframeIndices duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
        }
    }
    for (CEModel *child in _childObjects) {
        child.showWireframe = showWireframe;
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
    NSRange readRange = NSMakeRange(positionAttribute.elementOffset,
                                    positionAttribute.primaryCount * positionAttribute.primarySize);
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
    return identifierData;
}


- (void)testAutoGenerateIndicesBuffer {
    
}


@end
