//
//  CERenderer.h
//  CubeEngine
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "CEModel_Deprecated.h"

@interface CERenderer : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, readonly) EAGLContext *context;
@property (nonatomic, assign) GLKMatrix4 cameraProjectionMatrix;

//- (void)renderObject:(CEModel_Deprecated *)object;
- (void)renderObjects:(NSArray *)objects;

@end
