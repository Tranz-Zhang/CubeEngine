//
//  CEDefaultRenderer.h
//  CubeEngine
//
//  Created by chance on 5/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CECamera.h"
#import "CEProgramConfig.h"
#import "CEShadowLight.h"

@interface CEMainRenderer : NSObject

@property (nonatomic, strong) NSArray *lights;
@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, weak) CEShadowLight *shadowLight;

+ (instancetype)rendererWithConfig:(CEProgramConfig *)config;

- (void)renderObjects:(NSArray *)objects;
 

@end

#ifdef tes
#else
#endif

//Normal Map Rendering
//1. read the book
//2. prepare the data
//3. setup the shader
//4. test