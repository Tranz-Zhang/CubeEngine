//
//  CEMeterial.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEMaterial : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *textureMap;
@property (nonatomic, strong) NSString *normalMap;

@property (nonatomic, assign) GLKVector3 emission;
@property (nonatomic, assign) GLKVector3 ambient;
@property (nonatomic, assign) GLKVector3 diffuse;
@property (nonatomic, assign) GLKVector3 specular;
@property (nonatomic, assign) float shiniess;
@property (nonatomic, assign) float exponent;

@end


