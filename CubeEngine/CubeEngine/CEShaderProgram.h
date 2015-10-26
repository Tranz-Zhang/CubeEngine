//
//  CEShaderProgram.h
//  CubeEngine
//
//  Created by chance on 9/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEProgram.h"
#import "CEShaderInfo.h"
#import "CEVBOAttribute.h"
#import "CEShaderUniformDefines.h"

/**
 As a basic class, CEShaderProgram is used for compiling shader program with CEShaderInfo.
 
 */

@interface CEShaderProgram : NSObject {
    CEProgram *_program;
    NSArray *_attributes;
}

@property (nonatomic, readonly) NSArray *attributes; // array of CEVBOAttributeName
@property (nonatomic, readonly) uint32_t attributesType; // attritube array type
@property (nonatomic, readonly) uint32_t textureUnitCount; // units of texture in program

+ (instancetype)buildProgramWithShaderInfo:(CEShaderInfo *)shaderInfo;

- (void)use;

/** called when finished building program */
- (void)onProgramSetup;

@end
