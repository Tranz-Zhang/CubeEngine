//
//  CELightUniformInfo.h
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, CELightType) {
    CELightTypeDirectional = 1,
    CELightTypePoint,
    CELightTypeSpot,
};

// Save the uniform index of LightInfo struct in the program
@interface CELightInfo : NSObject

@property (nonatomic) CELightType lightType;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) GLKVector4 lightPosition;
@property (nonatomic) GLKVector3 lightDirection;
@property (nonatomic) GLKVector3 lightColor;

@property (nonatomic) GLKVector3 ambientColor;
@property (nonatomic) GLfloat specularIntensity;
@property (nonatomic) GLfloat shiniess;
@property (nonatomic) GLfloat attenuation;
@property (nonatomic) GLfloat spotCosCutOff;
@property (nonatomic) GLfloat spotExponent;

@end
