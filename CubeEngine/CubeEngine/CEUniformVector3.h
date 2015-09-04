//
//  CEShaderVector3.h
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"

@interface CEUniformVector3 : CEShaderVariable

@property (nonatomic, assign) GLKVector3 vector3;

@end
