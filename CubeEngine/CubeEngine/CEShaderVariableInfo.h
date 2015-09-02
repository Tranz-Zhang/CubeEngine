//
//  CEShaderVariableInfo.h
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"
#import "CEShaderDeclarationProtocol.h"

typedef NS_ENUM(int, CEShaderVariableUsage) {
    CEShaderVariableUsageNone = 0,
    CEShaderVariableUsageUniform,
    CEShaderVariableUsageAttribute,
    CEShaderVariableUsageVarying,
};

NSString *CEShaderVariableUsageString(CEShaderVariableUsage usage);
CEShaderVariableUsage CEShaderVariableUsageFromString(NSString *usageString);

/*
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
NSString *CEShaderVariableTypeStringWithType(CEShaderVariableType type);
//*/

@interface CEShaderVariableInfo : NSObject <CEJsonCoding, CEShaderDeclarationProtocol>

@property (nonatomic, readonly) NSUInteger variableID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *precision;
@property (nonatomic, readonly) CEShaderVariableUsage usage;

- (BOOL)isEqual:(CEShaderVariableInfo *)object;
- (NSUInteger)hash;

@end

