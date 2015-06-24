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
    
    NSSet *_models;
    NSSet *_lights;
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


- (NSSet *)allModels {
    return _models;
}

- (NSSet *)allLights {
    return _lights;
}

#pragma mark - Model
- (void)addModel:(CEModel *)model {
    if ([model isKindOfClass:[CEModel class]] &&
        ![_models containsObject:model]) {
        NSMutableSet *tmpList = [NSMutableSet setWithSet:_models];
        [tmpList addObject:model];
        _models = tmpList.copy;
        
    } else {
        CEError(@"Can not add model to scene");
    }
}


- (void)removeModel:(CEModel *)model {
    if ([_models containsObject:model]) {
        NSMutableSet *tmpList = [NSMutableSet setWithSet:_models];
        [tmpList removeObject:model];
        _models = tmpList.copy;
    }
}


- (void)addModels:(NSArray *)models {
    if (!models.count) return;
    NSMutableSet *tmpList = [NSMutableSet setWithSet:_models];
    for (CEModel *model in models) {
        if ([model isKindOfClass:[CEModel class]] &&
            ![tmpList containsObject:model]) {
            [tmpList addObject:model];
        }
    }
    _models = tmpList.copy;
}


- (void)removeModels:(NSArray *)models {
    if (!models.count) return;
    NSMutableSet *tmpList = [NSMutableSet setWithSet:_models];
    for (CEModel *model in models) {
        if ([tmpList containsObject:model]) {
            [tmpList removeObject:model];
        }
    }
    _models = tmpList.copy;
}


#pragma mark - Light
- (void)addLight:(CELight *)light {
    if (_lights.count < _maxLightCount &&
        [light isKindOfClass:[CELight class]] &&
        ![_lights containsObject:light]) {
        
        NSMutableSet *tmpList = [NSMutableSet setWithSet:_lights];
        [tmpList addObject:light];
        _lights = tmpList.copy;
    }
}


- (void)removeLight:(CELight *)light {
    if ([_lights containsObject:light]) {
        NSMutableSet *tmpList = [NSMutableSet setWithSet:_lights];
        [tmpList removeObject:light];
        _lights = tmpList.copy;
    }
}


@end
