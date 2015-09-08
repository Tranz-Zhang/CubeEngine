//
//  CEShaderLightInfo.m
//  CubeEngine
//
//  Created by chance on 8/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformLightInfo.h"
#import "CEShaderVariable_privates.h"

@implementation CEUniformLightInfo

- (instancetype)initWithName:(NSString *)name {
    self = [super initWithName:name];
    if (self) {
        
    }
    return self;
}


- (NSString *)dataType {
    return @"LightInfo";
}


- (BOOL)setupIndexWithProgram:(CEProgram *)program {
    _isEnabled = [[CEUniformBool alloc]initWithName:[NSString stringWithFormat:@"%@.IsEnabled", self.name]];
    if (![_isEnabled setupIndexWithProgram:program]) {
        _isEnabled = nil;
    }
    _lightType = [[CEUniformInteger alloc] initWithName:[NSString stringWithFormat:@"%@.LightType", self.name]];
    if (![_lightType setupIndexWithProgram:program]) {
        _lightType = nil;
    }
    _lightPosition = [[CEUniformVector4 alloc] initWithName:[NSString stringWithFormat:@"%@.LightPosition", self.name]];
    if (![_lightPosition setupIndexWithProgram:program]) {
        _lightPosition = nil;
    }
    _lightDirection = [[CEUniformVector3 alloc] initWithName:[NSString stringWithFormat:@"%@.LightDirection", self.name]];
    if (![_lightDirection setupIndexWithProgram:program]) {
        _lightDirection = nil;
    }
    _lightColor = [[CEUniformVector3 alloc] initWithName:[NSString stringWithFormat:@"%@.LightColor", self.name]];
    if (![_lightColor setupIndexWithProgram:program]) {
        _lightColor = nil;
    }
    _attenuation = [[CEUniformFloat alloc] initWithName:[NSString stringWithFormat:@"%@.Attenuation", self.name]];
    if (![_attenuation setupIndexWithProgram:program]) {
        _attenuation = nil;
    }
    _spotConsCutOff = [[CEUniformFloat alloc] initWithName:[NSString stringWithFormat:@"%@.SpotConsCutoff", self.name]];
    if (![_spotConsCutOff setupIndexWithProgram:program]) {
        _spotConsCutOff = nil;
    }
    _spotExponent = [[CEUniformFloat alloc] initWithName:[NSString stringWithFormat:@"%@.SpotExponent", self.name]];
    if (![_spotExponent setupIndexWithProgram:program]) {
        _spotExponent = nil;
    }
    
    return _isEnabled && _lightType && _lightPosition && _lightDirection &&
           _lightColor && _attenuation && _spotConsCutOff && _spotExponent;
}


- (NSString *)description {
    return [@[[_isEnabled description],
              [_lightType description],
              [_lightPosition description],
              [_lightDirection description],
              [_lightColor description],
              [_attenuation description],
              [_spotConsCutOff description],
              [_spotExponent description]]
            description];
}

@end
