//
//  CEShaderAttribute.h
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"
#import "CEVBOAttribute.h"

@interface CEShaderAttribute : CEShaderVariable

@property (nonatomic, readonly) GLuint variableCount;
@property (nonatomic, strong) CEVBOAttribute *attribute;

- (instancetype)initWithName:(NSString *)name
                   precision:(CEShaderDataPrecision)precision
               variableCount:(GLint)variableCount;


@end
