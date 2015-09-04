//
//  CEShaderLightInfo.m
//  CubeEngine
//
//  Created by chance on 8/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderLightInfo.h"


@implementation CEShaderLightInfo

- (instancetype)initWithName:(NSString *)name {
    self = [super initWithName:name];
    if (self) {
        _isEnabled =        [[CEUniformBool alloc]initWithName:@"IsEnabled"];
        _lightType =        [[CEUniformInteger alloc] initWithName:@"LightType"];
        _lightPosition =    [[CEUniformVector4 alloc] initWithName:@"LightPosition"];
        _lightDirection =   [[CEUniformVector3 alloc] initWithName:@"LightDirection"];
        _lightColor =       [[CEUniformVector3 alloc] initWithName:@"LightColor"];
        _attenuation =      [[CEUniformFloat alloc] initWithName:@"Attenuation"];
        _spotConsCutOff =   [[CEUniformFloat alloc] initWithName:@"SpotConsCutoff"];
        _spotExponent =     [[CEUniformFloat alloc] initWithName:@"SpotExponent"];
    }
    return self;
}


- (NSString *)dataType {
    return @"LightInfo";
}


@end
