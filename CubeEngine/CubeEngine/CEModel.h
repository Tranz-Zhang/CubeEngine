//
//  CEObject.h
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEObject.h"

typedef NS_OPTIONS(NSInteger, CEAxisMask) {
    CEAxisNone = 0,
    CEAxisX = 1 << 0,
    CEAxisY = 1 << 1,
    CEAxisZ = 1 << 2,
};


typedef NS_ENUM(NSInteger, CEVertextDataType) {
    CEVertextDataType_V3 = 0,   // vertex XYZ                           (size:3)
    CEVertextDataType_V3N3,     // vertex XYZ + normal XYZ              (size:6)
    CEVertextDataType_V3N3T2,   // vertex XYZ + normal XYZ + texture UV (size:8)
};

@interface CEModel : CEObject

// size of the model
@property (atomic, readonly) GLKVector3 bounds;

+ (instancetype)modelWithVertexData:(NSData *)vertexData type:(CEVertextDataType)dataType;


@end




