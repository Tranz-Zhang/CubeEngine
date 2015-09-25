//
//  CETextureInfo.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CETextureFileInfo : CEManagedObject

BIND_OBJECT_ID(textureID);
@property (nonatomic, assign) int32_t textureID;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *diffuseTextureRange;
@property (nonatomic, strong) NSString *normalTextureRange;
@property (nonatomic, strong) NSString *specularTextureRange;

@end
