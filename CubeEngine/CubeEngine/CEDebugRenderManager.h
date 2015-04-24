//
//  CEDebugRenderManager.h
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CECamera.h"

@interface CEDebugRenderManager : NSObject

@property (nonatomic, weak) CECamera *camera;

- (instancetype)initWithContext:(EAGLContext *)context;

// render wireframe of the object if model.showWireframe is enabled
- (void)renderWireframeForModels:(NSArray *)models;

// render virsul light models
- (void)renderLights:(NSArray *)lights;

// currently this method just render a world original point cooridnate
- (void)renderWorldSpaceCoordinates;

@end
