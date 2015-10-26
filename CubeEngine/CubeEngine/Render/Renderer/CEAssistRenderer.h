//
//  CERenderer_Accessory.h
//  CubeEngine
//
//  Created by chance on 4/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CELight.h"
#import "CECamera.h"

/**
 Use to render accessory info of the model, like bounds, local coordinate indicator
 */
@interface CEAssistRenderer : NSObject

@property (nonatomic, weak) CECamera *camera;

- (void)renderBoundsForObjects:(NSArray *)objects;

- (void)renderLights:(NSArray *)lights;

- (void)renderWorldOriginCoordinate;

@end
