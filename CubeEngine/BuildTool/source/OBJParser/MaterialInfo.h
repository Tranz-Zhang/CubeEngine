//
//  MaterialInfo.h
//  CubeEngine
//
//  Created by chance on 9/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "TextureInfo.h"

@interface MaterialInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) uint32_t resourceID;
@property (nonatomic, assign) CEMaterialType materialType;

@property (nonatomic, strong) TextureInfo *diffuseTexture;
@property (nonatomic, strong) TextureInfo *normalTexture;
@property (nonatomic, strong) TextureInfo *specularTexture;

@property (nonatomic, assign) GLKVector3 ambientColor;
@property (nonatomic, assign) GLKVector3 diffuseColor; // base color
@property (nonatomic, assign) GLKVector3 specularColor;
@property (nonatomic, assign) float shininessExponent;

@property (nonatomic, assign) float transparency;

@end
