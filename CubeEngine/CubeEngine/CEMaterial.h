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

@interface CEMaterial : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CEMaterialType materialType;

@property (nonatomic, strong) NSString *diffuseTexture;
@property (nonatomic, strong) NSString *normalTexture;

@property (nonatomic, assign) GLKVector3 emission;
@property (nonatomic, assign) GLKVector3 ambient;
@property (nonatomic, assign) GLKVector3 diffuse;
@property (nonatomic, assign) GLKVector3 specular;
@property (nonatomic, assign) float shiniess;
@property (nonatomic, assign) float exponent;

@property (nonatomic, assign) float transparency;

@end


