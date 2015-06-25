//
//  CEDefaultRenderer.h
//  CubeEngine
//
//  Created by chance on 5/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CECamera.h"
#import "CEProgramConfig.h"
#import "CEShadowLight.h"

@interface CEMainRenderer : NSObject

@property (nonatomic, strong) NSSet *lights;
@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, weak) CEShadowLight *shadowLight;

+ (instancetype)rendererWithConfig:(CEProgramConfig *)config;

- (void)renderObjects:(NSSet *)objects;
 

@end
