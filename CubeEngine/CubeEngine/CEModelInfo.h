//
//  CEObjFileInfo.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CEModelInfo : CEManagedObject

BIND_OBJECT_ID(modelName);
@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, assign) int32_t vertexDataID;
@property (nonatomic, strong) NSArray *meshIDs;

@end
