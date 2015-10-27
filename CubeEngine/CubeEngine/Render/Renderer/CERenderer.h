//
//  CERenderer.h
//  CubeEngine
//
//  Created by chance on 10/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderProgram.h"
#import "CERenderObject.h"
#import "CECamera.h"
#import "CELight.h"


@interface CERenderer : NSObject {
    CEShaderProgram *_program;
    __weak CECamera *_camera;
    __weak CELight *_mainLight;
}

@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, weak) CELight *mainLight;

- (BOOL)renderObjects:(NSArray *)objects;

@end
