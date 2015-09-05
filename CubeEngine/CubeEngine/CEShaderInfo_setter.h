//
//  CEShaderInfo_setter.h
//  CubeEngine
//
//  Created by chance on 9/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderInfo.h"

@interface CEShaderInfo ()

@property (nonatomic, strong, readwrite) NSDictionary *attributeDict;
@property (nonatomic, strong, readwrite) NSDictionary *uniformsDict;
@property (nonatomic, strong, readwrite) NSString *vertexShader;
@property (nonatomic, strong, readwrite) NSString *fragmentShader;

@end
