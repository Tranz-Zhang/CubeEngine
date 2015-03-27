//
//  CELinesProgram.h
//  CubeEngine
//
//  Created by chance on 15/3/16.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEProgram.h"

@interface CELinesProgram : CEProgram

@property (nonatomic, readonly) GLint attributePosotion;
@property (nonatomic, readonly) GLint uniformProjection;
@property (nonatomic, readonly) GLint uniformDrawColor;

+ (instancetype)defaultProgram;

@end
