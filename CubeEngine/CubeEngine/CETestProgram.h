//
//  CETestProgram.h
//  CubeEngine
//
//  Created by chance on 15/3/10.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEProgram.h"

@interface CETestProgram : CEProgram

//GLint _attribPosition;
//GLint _uniformProjection;
//GLint _uniformDrawColor;

@property (nonatomic, readonly) GLint attributePosotion;
@property (nonatomic, readonly) GLint uniformProjection;
@property (nonatomic, readonly) GLint uniformDrawColor;

+ (instancetype)defaultProgram;

@end
