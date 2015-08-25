//
//  TestCodingGroup.h
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderVariableInfo.h"

@interface CEShaderFileInfo : NSObject <CEJsonCoding>

@property (nonatomic, strong) NSArray *vertexShaderStructs;     // struct declarations
@property (nonatomic, strong) NSArray *vertexShaderVariables;   // list of CEShaderVariableInfo
@property (nonatomic, strong) NSArray *vertexShaderFunctions;   // list of CEShaderFunctionInfo

@property (nonatomic, strong) NSArray *fragmentShaderStructs;   // struct declarations
@property (nonatomic, strong) NSArray *fragmentShaderVariables; // list of CEShaderVariableInfo
@property (nonatomic, strong) NSArray *fragmentShaderFunctions; // list of CEShaderFunctionInfo

@end
