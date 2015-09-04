//
//  CEShaderProgram.h
//  CubeEngine
//
//  Created by chance on 9/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderInfo.h"

@interface CEShaderProgram : NSObject

+ (instancetype)buildProgramWithShaderInfo:(CEShaderInfo *)shaderInfo;

@end
