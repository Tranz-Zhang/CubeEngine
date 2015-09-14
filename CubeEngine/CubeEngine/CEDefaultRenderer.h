//
//  CEDefaultRenderer.h
//  CubeEngine
//
//  Created by chance on 9/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CECamera.h"
#import "CELight.h"
#import "CERenderConfig.h"

@interface CEDefaultRenderer : NSObject

@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, weak) CELight *mainLight;

+ (instancetype)rendererWithConfig:(CERenderConfig *)config;

- (void)renderObjects:(NSArray *)objects;

@end


