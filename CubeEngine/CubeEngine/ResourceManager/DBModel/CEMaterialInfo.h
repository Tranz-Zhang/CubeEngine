//
//  CEMaterialInfo.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CEMaterialInfo : CEManagedObject

BIND_OBJECT_ID(materialID);
@property (nonatomic, assign) int32_t materialID;

@property (nonatomic, assign) int32_t materialType;
@property (nonatomic, assign) int32_t diffuseTextureID;
@property (nonatomic, assign) int32_t normalTextureID;
@property (nonatomic, assign) int32_t specularTextureID;

@property (nonatomic, strong) NSData *ambientColorData; // data of GLKVector3
@property (nonatomic, strong) NSData *diffuseColorData; // data of GLKVector3
@property (nonatomic, strong) NSData *specularColorData;// data of GLKVector3
@property (nonatomic, assign) float shininessExponent;
@property (nonatomic, assign) float transparent;

@end
