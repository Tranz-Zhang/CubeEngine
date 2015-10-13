//
//  MeshInfo.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "MeshInfo.h"
#import "NvTriStrip.h"

static uint32_t sNextResourceID = kBaseMeshID;

@implementation MeshInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _resourceID = sNextResourceID++;
    }
    return self;
}


- (GLenum)indicePrimaryType {
    if (_maxIndex > 65525) {
        return GL_UNSIGNED_INT;
        
    } else if (_maxIndex > 255) {
        return GL_UNSIGNED_SHORT;
        
    } else {
        return GL_UNSIGNED_BYTE;
    }
}


- (NSData *)buildIndiceData {
    NSMutableData *indiceData = [NSMutableData data];
    if (_maxIndex > 65525) {
        for (NSNumber *indexValue in _indicesList) {
            uint32_t index = [indexValue unsignedIntValue];
            [indiceData appendBytes:&index length:sizeof(uint32_t)];
        }
        
    } else if (_maxIndex > 255) {
        for (NSNumber *indexValue in _indicesList) {
            unsigned short index = [indexValue unsignedShortValue];
            [indiceData appendBytes:&index length:sizeof(unsigned short)];
        }
        
    } else {
        for (NSNumber *indexValue in _indicesList) {
            unsigned char index = [indexValue unsignedCharValue];
            [indiceData appendBytes:&index length:sizeof(unsigned char)];
        }
    }
    _indiceCount = (uint32_t)_indicesList.count;
    return indiceData.copy;
}


- (NSData *)buildOptimizedIndiceData {
    NSMutableData *preIndiceData = [NSMutableData data];
    for (NSNumber *indexValue in _indicesList) {
        unsigned short index = [indexValue unsignedShortValue];
        [preIndiceData appendBytes:&index length:sizeof(unsigned short)];
    }
    
    NSData *optimizedIndiceData = nil;
    PrimitiveGroup *primitivegroup;
    unsigned short n_group = 0;
    unsigned short *indiceDataPtr = (unsigned short *)preIndiceData.bytes;
    
//    for (int i = 0; i < _indicesList.count; i++) {
//        printf("%d\n", indiceDataPtr[i]);
//    }
    
    SetCacheSize(128);
    if( GenerateStrips(indiceDataPtr,
                       (unsigned short)_indicesList.count,
                       &primitivegroup,
                       &n_group,
                       true ) ) {
        if(primitivegroup[0].numIndices < _indicesList.count) {
//            objmesh->objtrianglelist[ i ].mode = GL_TRIANGLE_STRIP;
//            objmesh->objtrianglelist[ i ].n_indice_array = primitivegroup[ 0 ].numIndices;
            _indiceCount = primitivegroup[ 0 ].numIndices;
            uint32_t dataLength = _indiceCount * sizeof( unsigned short );
            optimizedIndiceData = [NSData dataWithBytes:primitivegroup[0].indices length:dataLength];
        }
        
        delete[] primitivegroup;
    }
    return optimizedIndiceData;
}

@end
