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
#import "CEObject.h"

@interface CERenderer : NSObject
@property (nonatomic, readonly) EAGLContext *context;

- (void)renderObject:(CEObject *)object;

@end
