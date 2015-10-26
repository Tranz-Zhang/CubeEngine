//
//  CEScene_Rendering.h
//  CubeEngine
//
//  Created by chance on 5/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEScene.h"
#import "CERenderCore.h"



@interface CEScene ()

+ (instancetype)currentScene;
+ (void)setCurrentScene:(CEScene *)scene;

- (instancetype)initWithContext:(EAGLContext *)context;

@property (nonatomic, readonly) EAGLContext *context;
@property (nonatomic, readonly) GLKVector4 vec4BackgroundColor;
@property (nonatomic, readonly) CERenderCore *renderCore;

@property (nonatomic, readwrite) NSInteger maxLightCount;
@property (nonatomic, assign) BOOL enableDebug;


@end

