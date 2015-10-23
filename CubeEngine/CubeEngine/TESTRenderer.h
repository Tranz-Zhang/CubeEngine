//
//  TESTRenderer.h
//  CubeEngine
//
//  Created by chance on 10/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CECamera.h"
#import "CEProgramConfig.h"
#import "CELight.h"

@interface TESTRenderer : NSObject

@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, weak) CELight *mainLight;

- (void)renderObjects:(NSArray *)objects;

@end
