//
//  CEShaderMatrix4.h
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"

@interface CEUniformMatrix4 : CEShaderVariable

@property (nonatomic, assign) GLKMatrix4 matrix4;

@end
