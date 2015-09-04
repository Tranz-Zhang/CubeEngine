//
//  CEShaderLightInfo.h
//  CubeEngine
//
//  Created by chance on 8/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"

// Light Info Struct
@interface CEShaderLightInfo : CEShaderVariable

@property (nonatomic, readonly) CEUniformBool *isEnabled;
@property (nonatomic, readonly) CEUniformInteger *lightType;
@property (nonatomic, readonly) CEUniformVector4 *lightPosition;
@property (nonatomic, readonly) CEUniformVector3 *lightDirection;
@property (nonatomic, readonly) CEUniformVector3 *lightColor;
@property (nonatomic, readonly) CEUniformFloat *attenuation;
@property (nonatomic, readonly) CEUniformFloat *spotConsCutOff;
@property (nonatomic, readonly) CEUniformFloat *spotExponent;

@end

