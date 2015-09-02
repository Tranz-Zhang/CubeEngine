//
//  CEShaderStructInfo.h
//  CubeEngine
//
//  Created by chance on 9/1/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"
#import "CEShaderVariableInfo.h"


@interface CEShaderStructInfo : NSObject <CEJsonCoding>

@property (nonatomic, readonly) NSUInteger structID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray *variables;

- (NSString *)declarationString;

- (BOOL)isEqual:(CEShaderStructInfo *)object;
- (NSUInteger)hash;

@end
