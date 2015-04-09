//
//  CEObject.m
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEModel_Deprecated.h"
#import "CEModel_Rendering.h"

@implementation CEModel_Deprecated {
    
}


+ (instancetype)modelWithVertexData:(NSData *)vertexData type:(CEVertextDataType)dataType {
    CEModel_Deprecated *model = [[CEModel_Deprecated alloc] initWithVertexData:vertexData dataType:dataType];
    if (!model.vertextCount) {
        CEError(@"Can not initialized CEModel, vertextCount is 0");
        return nil;
    }
    return model;
}


- (instancetype)initWithVertexData:(NSData *)vertexData
                          dataType:(CEVertextDataType)dataType
{
    self = [super init];
    if (self) {
        _vertexData = vertexData;
        _dataType = dataType;
        _vertexBufferIndex = 0;
        _vertextCount = 0;
        [self setupModel];
    }
    return self;
}


- (void)dealloc {
    if (_vertexBufferIndex) {
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
        glBufferData(GL_ARRAY_BUFFER, 0, NULL, GL_STATIC_DRAW);
        glDeleteBuffers(1, &_vertexBufferIndex);
    }
}

- (void)setupModel {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    // calculate vertex count
    NSInteger elementCount = [self elementCountForDataType:_dataType];
    NSInteger elementSize = elementCount * sizeof(GLfloat);
    if (_vertexData.length % elementSize) {
        CEError(@"Wrong vertext size");
        return;
    }
    _vertextCount = (int)(_vertexData.length / elementSize);
    
    // calculate model size
    NSRange readRange = NSMakeRange(0, 3 * sizeof(GLfloat));
    GLfloat maxX = FLT_MIN, maxY = FLT_MIN, maxZ = FLT_MIN;
    GLfloat minX = FLT_MAX, minY = FLT_MAX, minZ = FLT_MAX;
    for (int i = 0; i < _vertextCount; i++) {
        GLfloat vertexLocation[3];
        [_vertexData getBytes:vertexLocation range:readRange];
        maxX = MAX(maxX, vertexLocation[0]);
        maxY = MAX(maxY, vertexLocation[1]);
        maxZ = MAX(maxZ, vertexLocation[2]);
        minX = MIN(minX, vertexLocation[0]);
        minY = MIN(minY, vertexLocation[1]);
        minZ = MIN(minZ, vertexLocation[2]);
        readRange.location += elementSize;
    }
    
    // original offset
//    _originalOffset = GLKVector3Make((maxX + minX) / 2,
//                                     (maxY + minY) / 2,
//                                     (maxZ + minZ) / 2);
    _bounds = GLKVector3Make(maxX - minX, maxY - minY, maxZ - minZ);
    
    CELog(@"Setup model OK: %.8f", CFAbsoluteTimeGetCurrent() - startTime);
}

- (NSUInteger)elementCountForDataType:(CEVertextDataType)dataType {
    switch (dataType) {
        case CEVertextDataType_V3:
            return 3;
        case CEVertextDataType_V3N3:
            return 6;
        case CEVertextDataType_V3N3T2:
            return 8;
            
        default:
            return 0;
    }
}


//- (void)setRotation:(GLfloat)rotationDegree onPivot:(CERotationPivot)rotationPivot {
//    @synchronized(self) {
//        _rotationDegree = rotationDegree;
//        _rotationPivot = rotationPivot;
//    }
//}

#pragma mark - Rendering
- (void)generateVertexBufferInContext:(EAGLContext *)context {
    if (!_vertexBufferIndex && _vertexData.length) {
        [EAGLContext setCurrentContext:context];
        glGenBuffers(1, &_vertexBufferIndex);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
        glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
    }
}


//- (GLKMatrix4)transformMatrix {
//#warning Consider offer center transfrom
//    @synchronized(self) {
//        GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(_location.x,
//                                                              _location.y,
//                                                              _location.z);
//        if (_rotationPivot) {
//            tranformMatrix = GLKMatrix4Rotate(tranformMatrix,
//                                              GLKMathDegreesToRadians(_rotationDegree),
//                                              _rotationPivot & CERotationPivotX ? 1 : 0,
//                                              _rotationPivot & CERotationPivotY ? 1 : 0,
//                                              _rotationPivot & CERotationPivotZ ? 1 : 0);
//        }
//        if (_scale != 1) {
//            GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(_scale, _scale, _scale);
//            GLKMatrix4 adjustMatrix = GLKMatrix4MakeTranslation(-1, 0, 0);
//            GLKMatrix4 transposeAdjustMatrix = GLKMatrix4Invert(adjustMatrix, NULL);
//            tranformMatrix = GLKMatrix4Multiply(transposeAdjustMatrix, GLKMatrix4Multiply(scaleMatrix, GLKMatrix4Multiply(adjustMatrix, tranformMatrix)));
//        }
//        return tranformMatrix;
//    }
//}



@end


