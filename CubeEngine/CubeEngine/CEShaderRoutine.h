//
//  CEShaderRoutine.h
//  CubeEngine
//
//  Created by chance on 8/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderVariableDefines.h"

/**
 CEShaderRoutine represents an execution routine in the shader, like lighting
 calculation, shadow calculation, texture calculation etc. The whole idea is to
 separate the shader into different code blocks which can be replaced by other 
 code block.
 
 */
@interface CEShaderRoutine : NSObject {
    NSMutableArray *_subRoutines;
}

/** 
 Here's the declatation of variables used in vertext shader.
 
 @note: about the keyword "required"
 If the implementation used some variables not come from either "uniform" nor
 "attribute", you can use "required" keyword to indicate that this variable 
 comes from other implemenation. The system will automatically check the required
 variables for you.
*/
- (NSString *)vertexShaderVariables;


/* codes to execute in vertex shader, could be null */
- (NSString *)vertexShaderImplementation;


/**
 Here's the declatation of variables used in fragment shader.
 
 @note: about the keyword "required"
 If the implementation used some variables not come from "either" uniform nor
 "attribute", you can use "required" keyword to indicate that this variable
 comes from other implemenation. The system will automatically check the required
 variables for you.
 */
- (NSString *)fragmentShaderVariables;


/**
 codes to execute in fragment shader, could be null
 */
- (NSString *)fragmentShaderImplementation;


#pragma mark - Sub Routine
/**
 A sub routine's implementation will be added to the end to the current routine's
 implementation one by one.

 @discussion: Variables between routines
 For example, routine1 has a vec4 variable "A". And when routine2 added after
 routine1, it routine2 use variable "A" if it declare the variable as 
 "required vec4 A" in vertexShaderVariables/fragmentShaderVariables.
 
 */
- (void)addSubRoutine:(CEShaderRoutine *)subRoutine;


@end




