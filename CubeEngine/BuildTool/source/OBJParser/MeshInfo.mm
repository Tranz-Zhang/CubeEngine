//
//  MeshInfo.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "MeshInfo.h"
#import "NvTriStrip.h"

@implementation MeshInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
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
//        NSLog(@"%d\n", indiceDataPtr[i]);
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


- (void)setName:(NSString *)name {
    if (![_name isEqualToString:name]) {
        _name = name;
        _resourceID = HashValueWithString(name);
    }
}


- (BOOL)isEqual:(MeshInfo *)other {
    if (other == self) {
        return YES;
    } else {
        return _resourceID && _resourceID == other.resourceID;
    }
}


- (NSUInteger)hash {
    return _resourceID;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"Mesh[%08X]-%@:\nindiceCount:%d\nmaxIndice:%d\nprimaryType:%04X\ndrawMode%04X\n- Material:{%@}\n", _resourceID, _name, _indiceCount, _maxIndex, _indicePrimaryType, _drawMode, _materialInfo];
}


@end

