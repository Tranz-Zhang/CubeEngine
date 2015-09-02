//
//  CEShaderProfile.h
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderVariableInfo.h"
#import "CEShaderStructInfo.h"

@interface CEShaderProfile : NSObject <CEJsonCoding>

@property (nonatomic, readonly) NSArray *structs;     // array of CEShaderStructInfo
@property (nonatomic, readonly) NSArray *variables;   // array of CEShaderVariableInfo
@property (nonatomic, readonly) CEShaderFunctionInfo *function;

@end
