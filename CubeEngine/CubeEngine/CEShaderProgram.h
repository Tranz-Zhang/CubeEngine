//
//  CEShaderProgram.h
//  CubeEngine
//
//  Created by chance on 8/12/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderRoutine.h"

@interface CEShaderProgram : NSObject


// ... include properties

- (void)addProcess:(CEShaderRoutine *)process;

- (NSString *)vertexShaderString;
- (NSString *)fragmentShaderString;

@end
