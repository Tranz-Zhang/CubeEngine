//
//  CEShaderSample2D.h
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"

@interface CEShaderSample2D : CEShaderVariable

@property (nonatomic, assign) GLuint textureID;

- (void)setTextureIndex:(int)textureIndex;

@end
