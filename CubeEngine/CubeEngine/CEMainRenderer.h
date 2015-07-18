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
#import "CELight.h"

@interface CEMainRenderer : NSObject

@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, weak) CELight *mainLight;

+ (instancetype)rendererWithConfig:(CEProgramConfig *)config;

- (void)renderObjects:(NSArray *)objects;
 

@end


