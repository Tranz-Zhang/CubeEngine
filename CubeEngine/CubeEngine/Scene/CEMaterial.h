//
//  CEMeterial.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CECommon.h"

@interface CEMaterial : NSObject<NSCopying>

@property (nonatomic, strong) NSString *name DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign) CEMaterialType materialType;

@property (nonatomic, strong) NSString *diffuseTexture DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSString *normalTexture DEPRECATED_ATTRIBUTE;

@property (nonatomic, assign) uint32_t diffuseTextureID;
@property (nonatomic, assign) uint32_t normalTextureID;
@property (nonatomic, assign) uint32_t specularTextureID;

@property (nonatomic, assign) GLKVector3 ambientColor;
@property (nonatomic, assign) GLKVector3 diffuseColor; // base color
@property (nonatomic, assign) GLKVector3 specularColor;
@property (nonatomic, assign) float shininessExponent;

@property (nonatomic, assign) float transparency;

@end


