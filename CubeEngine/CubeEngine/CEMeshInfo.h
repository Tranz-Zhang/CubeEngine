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
@property (nonatomic, strong) NSString *meshName;
@property (nonatomic, assign) int32_t materialID;
@property (nonatomic, assign) int32_t indicesDataRID;

@end
