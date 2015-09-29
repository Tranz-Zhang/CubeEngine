//
//  MeshInfo.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "MeshInfo.h"

@implementation MeshInfo

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
    return indiceData.copy;
}


@end
