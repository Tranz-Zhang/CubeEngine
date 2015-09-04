//
//  CEShaderInfo_setter.h
//  CubeEngine
//
//  Created by chance on 9/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderInfo.h"

@interface CEShaderInfo ()

@property (nonatomic, copy, readwrite) NSDictionary *variableInfos;

@property (nonatomic, copy, readwrite) NSString *vertexShader;
@property (nonatomic, copy, readwrite) NSString *fragmentShader;

@end
