//
//  CEModelInfo.h
//  CubeEngine
//
//  Created by chance on 9/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CEModelInfo : CEManagedObject

BIND_OBJECT_ID(name);

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) unsigned long vertexDataUID;
@property (nonatomic, assign) unsigned long diffuseTextureUID;
@property (nonatomic, assign) unsigned long normalTextureUID;

@property (nonatomic, strong) NSArray *childModelNames;

@end

