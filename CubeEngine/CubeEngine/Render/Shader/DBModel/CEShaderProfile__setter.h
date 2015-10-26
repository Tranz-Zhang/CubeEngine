//
//  CEShaderProfile__setter.h
//  CubeEngine
//
//  Created by chance on 9/1/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProfile.h"

@interface CEShaderProfile ()

@property (nonatomic, strong, readwrite) NSArray *structs;     // array of CEShaderStructInfo
@property (nonatomic, strong, readwrite) NSArray *variables;   // array of CEShaderVariableInfo
@property (nonatomic, strong, readwrite) CEShaderFunctionInfo *function;
@property (nonatomic, strong, readwrite) NSString *defaultPrecision;

@end
