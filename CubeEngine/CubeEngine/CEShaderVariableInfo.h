//
//  CEShaderVariableInfo.h
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"
#import "CEShaderVariable.h"

typedef NS_ENUM(int, CEShaderVariableUsage) {
    CEShaderVariableUsageNone = 0,
    CEShaderVariableUsageUniform,
    CEShaderVariableUsageAttribute,
    CEShaderVariableUsageVarying,
};

typedef NS_ENUM(int, CEShaderVariableType) {
    CEShaderVariableUnknown = -1,
    CEShaderVariableVoid = 0,
    CEShaderVariableBool,
    CEShaderVariableInt,
    CEShaderVariableFloat,
    CEShaderVariableVector2,
    CEShaderVariableVector3,
    CEShaderVariableVector4,
    CEShaderVariableMatrix2,
    CEShaderVariableMatrix3,
    CEShaderVariableMatrix4,
    CEShaderVariableSampler2D,
};

CEShaderVariableType CEShaderVariableTypeFromString(NSString *typeString);

@interface CEShaderVariableInfo : NSObject <CEJsonCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CEShaderVariableType type;
@property (nonatomic, strong) NSString *precision;
@property (nonatomic, assign) CEShaderVariableUsage usage;

- (BOOL)isEqual:(CEShaderVariableInfo *)object;
- (NSUInteger)hash;

- (CEShaderVariable *)toShaderVariable;

@end

