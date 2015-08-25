//
//  CEShaderVariableInfo.h
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"

typedef NS_ENUM(int, CEShaderVariableUsage) {
    CEShaderVariableUsageNone = 0,
    CEShaderVariableUsageUniform,
    CEShaderVariableUsageAttribute,
    CEShaderVariableUsageVarying,
};


@interface CEShaderVariableInfo : NSObject <CEJsonCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *precision;
@property (nonatomic, assign) CEShaderVariableUsage usage;

@end

