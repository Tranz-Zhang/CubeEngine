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

NSString *CEShaderVariableUsageString(CEShaderVariableUsage usage);
CEShaderVariableUsage CEShaderVariableUsageFromString(NSString *usageString);

@interface CEShaderVariableInfo : NSObject <CEJsonCoding>

@property (nonatomic, readonly) NSUInteger variableID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *precision;
@property (nonatomic, readonly) CEShaderVariableUsage usage;

- (NSString *)declarationString;

- (BOOL)isEqual:(CEShaderVariableInfo *)object;
- (NSUInteger)hash;

@end

