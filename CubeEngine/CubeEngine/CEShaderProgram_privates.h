//
//  CEShaderProgram_privates.h
//  CubeEngine
//
//  Created by chance on 9/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProgram.h"

@interface CEShaderProgram ()


/**
 return the uniform index for the specify varialbe.
 return -1 if varialbe is not availiable in shader program.
 */
- (GLint)uniformIndexOfVariable:(CEShaderVariable *)variable;

/**
 return the attribute index for the specify varialbe.
 return -1 if varialbe is not availiable in shader program.
 */
- (GLint)attributeIndexOfVariable:(CEShaderVariable *)variable;

@end
