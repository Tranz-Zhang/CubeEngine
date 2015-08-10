//
//  CEShaderLightInfo.h
//  CubeEngine
//
//  Created by chance on 8/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderStruct.h"

// Light Info Struct
@interface CEShaderLightInfo : CEShaderStruct

@property (nonatomic, readonly) CEShaderBool *isEnabled;
@property (nonatomic, readonly) CEShaderInteger *lightType;
@property (nonatomic, readonly) CEShaderVector4 *lightPosition;
@property (nonatomic, readonly) CEShaderVector3 *lightDirection;
@property (nonatomic, readonly) CEShaderVector3 *lightColor;
@property (nonatomic, readonly) CEShaderFloat *attenuation;
@property (nonatomic, readonly) CEShaderFloat *spotConsCutOff;
@property (nonatomic, readonly) CEShaderFloat *spotExponent;

@end
