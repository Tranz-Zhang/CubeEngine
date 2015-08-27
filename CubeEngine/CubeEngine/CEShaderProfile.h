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

@interface CEShaderProfile : NSObject <CEJsonCoding>

@property (nonatomic, strong) NSArray *structs;     // struct declarations
@property (nonatomic, strong) NSArray *variables;   // list of CEShaderVariableInfo
@property (nonatomic, strong) CEShaderFunctionInfo *function;

@end
