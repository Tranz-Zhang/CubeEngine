//
//  CERenderManager.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 RenderManager, it does:
 
 1. sort render objects into groups
 
 2. setup render resources
 
 3. manage different kinds of renderer
 
 4. render groups of objects using the right renderer
 
 5. render debug graphics
 */
@interface CERenderManager : NSObject

- (instancetype)initWithContext:(EAGLContext *)context;

- (void)renderCurrentScene;

@end

