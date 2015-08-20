//
//  CEShaderFileParser.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderFileInfo.h"
#import "CEShaderFunctionInfo.h"

/**
 CEShaderFileParser
 
 This parser will search the shader resources directory and find the the files that
 match {shaderName}.vert and {shaderName}.frag.
 
 The parasing job is mainly on shader variables and shader functions which define in
 shader files. The parse result store in CEShaderFileInfo.
 
 */
@interface CEShaderFileParser : NSObject

- (instancetype)initWithShaderName:(NSString *)shaderName;
- (CEShaderFileInfo *)parse;

@end
