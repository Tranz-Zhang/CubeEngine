//
//  CEMeterial.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, CEMaterialType) {
    CEMaterialSolid = 0,
    CEMaterialAlphaTested,
    CEMaterialTransparent,
};

@interface CEMaterial : NSObject<NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CEMaterialType materialType;

@property (nonatomic, strong) NSString *diffuseTexture;
@property (nonatomic, strong) NSString *normalTexture;

@property (nonatomic, assign) GLKVector3 ambientColor;
@property (nonatomic, assign) GLKVector3 diffuseColor; // base color
@property (nonatomic, assign) GLKVector3 specularColor;
@property (nonatomic, assign) float shininessExponent;

@property (nonatomic, assign) float transparency;

@end


