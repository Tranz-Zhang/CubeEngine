//
//  MTLInfo.h
//  CubeEngine
//
//  Created by chance on 9/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, MaterialType) {
    MaterialTypeSolid = 0,
    MaterialTypeAlphaTested,
    MaterialTypeTransparent,
};

@interface MTLInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) MaterialType materialType;

@property (nonatomic, strong) NSString *diffuseTextureName;
@property (nonatomic, strong) NSString *normalTextureName;

@property (nonatomic, assign) GLKVector3 ambientColor;
@property (nonatomic, assign) GLKVector3 diffuseColor; // base color
@property (nonatomic, assign) GLKVector3 specularColor;
@property (nonatomic, assign) float shininessExponent;

@property (nonatomic, assign) float transparency;

@end
