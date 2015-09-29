//
//  CEObjFileInfo.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CEObjFileInfo : CEManagedObject

BIND_OBJECT_ID(fileName);
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, assign) NSString *vertexDataPath;
@property (nonatomic, strong) NSArray *meshIDs;

@end
