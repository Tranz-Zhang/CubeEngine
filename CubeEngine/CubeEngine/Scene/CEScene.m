//
//  CEScene.m
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEScene.h"
#import "CEScene_Rendering.h"

@interface CEScene () {
    NSArray *_models;
}

@end


@implementation CEScene

static CEScene *sCurrentScene;

+ (instancetype)currentScene {
    return sCurrentScene;
}

+ (void)setCurrentScene:(CEScene *)scene {
    if (sCurrentScene != scene) {
        sCurrentScene = scene;
    }
}


- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _renderCore = [[CERenderCore alloc] initWithContext:context];
        
        _camera = [[CECamera alloc] init];
        _camera.radianDegree = 65;
        _camera.aspect = 320.0 / 568.0;
        _camera.nearZ = 0.1f;
        _camera.farZ = 100.0f;
        _camera.position = GLKVector3Make(0, 0, 4);        
    }
    return self;
}


#pragma mark - Setters & Getters
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = [backgroundColor copy];
        CGFloat red, green, blue, alpha;
        [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
        _vec4BackgroundColor = GLKVector4Make(red, green, blue, alpha);
    }
}


- (NSArray *)allModels {
    return _models;
}

#pragma mark - Model
- (void)addModel:(CEModel *)model {
    if ([model isKindOfClass:[CEModel class]] &&
        ![_models containsObject:model]) {
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:_models];
        [tmpList addObject:model];
        _models = tmpList.copy;
        
    } else {
        CEError(@"Can not add model to scene");
    }
}


- (void)removeModel:(CEModel *)model {
    if ([_models containsObject:model]) {
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:_models];
        [tmpList removeObject:model];
        _models = tmpList.copy;
    }
}



@end
