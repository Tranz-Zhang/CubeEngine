//
//  CEShaderBuilder.h
//  CubeEngine
//
//  Created by chance on 8/16/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderProgram.h"
#import "CEProgramConfig.h"

@interface CEProgramBuilder : NSObject

- (void)startBuildingNewProgram;

- (void)setRanderMode:(CERenderMode)renderMode;
- (void)enableLight:(BOOL)enabled;
- (void)enableTexture:(BOOL)enabled;
- (void)enableNormalMap:(BOOL)enabled;
- (void)enableShadowMap:(BOOL)enabled;

- (CEShaderProgram *)buildProgram;

@end

