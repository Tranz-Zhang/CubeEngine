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

@interface CEMainRenderer : NSObject

@property (nonatomic, strong) NSSet *lights;
@property (nonatomic, weak) CECamera *camera;


+ (instancetype)rendererWithConfig:(CEProgramConfig *)config;

- (void)renderObjects:(NSArray *)objects;
 

@end
