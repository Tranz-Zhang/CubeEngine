//
//  CETextureInfo.h
//  CubeEngine
//
//  Created by chance on 9/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CETextureInfo : CEManagedObject

BIND_OBJECT_ID(textureID);
@property (nonatomic, assign) int32_t textureID;
@property (nonatomic, assign) CGSize textureSize;

@end
