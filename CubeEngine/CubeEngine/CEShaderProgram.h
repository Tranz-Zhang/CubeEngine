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
#import "CEShaderVariable.h"

/**
 As a basic class, CEShaderProgram is used for compiling shader program with CEShaderInfo.
 
 */

@interface CEShaderProgram : NSObject {
    CEProgram *_program;
}

+ (instancetype)buildProgramWithShaderInfo:(CEShaderInfo *)shaderInfo;


@end
