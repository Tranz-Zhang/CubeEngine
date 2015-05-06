//
//  CEDebugRenderManager.h
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEDebugRenderManager : NSObject

- (instancetype)initWithContext:(EAGLContext *)context;

- (void)renderCurrentScene;

@end
