//
//  CEAttribute.h
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"
#import "CEVBOAttribute.h"


@interface CEAttribute : CEShaderVariable

@property (nonatomic, strong) CEVBOAttribute *attribute;

@end
