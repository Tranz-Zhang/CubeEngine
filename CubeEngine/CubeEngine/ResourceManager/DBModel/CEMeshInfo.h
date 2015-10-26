//
//  CEMeshInfo.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CEMeshInfo : CEManagedObject

BIND_OBJECT_ID(meshID);
@property (nonatomic, assign) int32_t meshID;
@property (nonatomic, assign) int32_t materialID;

@property (nonatomic, assign) uint32_t indiceCount;
@property (nonatomic, assign) GLenum indicePrimaryType; // GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE
@property (nonatomic, assign) GLenum drawMode;          // GL_TRIANGLES or GL_TRIANGLE_STRIP

@end
