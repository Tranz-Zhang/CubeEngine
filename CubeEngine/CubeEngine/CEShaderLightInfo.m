//
//  CEShaderLightInfo.m
//  CubeEngine
//
//  Created by chance on 8/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderLightInfo.h"
#import "CEShaderStruct_privates.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderLightInfo


- (instancetype)initWithName:(NSString *)name {
    self = [super initWithName:name];
    if (self) {
        _isEnabled =        [[CEShaderBool alloc] initWithName:@"IsEnabled"         precision:kCEPrecisionLowp];
        _lightType =        [[CEShaderInteger alloc] initWithName:@"LightType"      precision:kCEPrecisionLowp];
        _lightPosition =    [[CEShaderVector4 alloc] initWithName:@"LightPosition"  precision:kCEPrecisionMediump];
        _lightDirection =   [[CEShaderVector3 alloc] initWithName:@"LightDirection" precision:kCEPrecisionLowp];
        _lightColor =       [[CEShaderVector3 alloc] initWithName:@"LightColor"     precision:kCEPrecisionMediump];
        _attenuation =      [[CEShaderFloat alloc] initWithName:@"Attenuation"      precision:kCEPrecisionMediump];
        _spotConsCutOff =   [[CEShaderFloat alloc] initWithName:@"SpotConsCutoff"   precision:kCEPrecisionMediump];
        _spotExponent =     [[CEShaderFloat alloc] initWithName:@"SpotExponent"     precision:kCEPrecisionMediump];
    }
    return self;
}


+ (NSString *)structName {
    return @"LightInfo";
}


@end
