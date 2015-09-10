//
//  CETestRenderer.h
//  CubeEngine
//
//  Created by chance on 9/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CECamera.h"
#import "CELight.h"

@interface CETestRenderer : NSObject

@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, weak) CELight *mainLight;

- (void)renderObjects:(NSArray *)objects;

@end
