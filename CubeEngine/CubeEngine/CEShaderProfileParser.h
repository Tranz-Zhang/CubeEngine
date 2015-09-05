//
//  CEShaderProfileParser.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderProfile.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderVariableInfo.h"

/**
 CEShaderProfileParser
 
 This parser will search the shader resources directory and find the the files that
 match {shaderName}.vert and {shaderName}.frag.
 
 The parasing job is mainly on shader variables and shader functions which define in
 shader files. The parse result store in CEShaderFileInfo.
 
 */
@interface CEShaderProfileParser : NSObject

- (CEShaderProfile *)parseShaderString:(NSString *)shaderString;

@end

