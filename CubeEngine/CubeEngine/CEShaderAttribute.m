//
//  CEShaderAttribute.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderAttribute.h"

@implementation CEShaderAttribute

- (void)setAttribute:(CEVBOAttribute *)attribute {
    _attribute = attribute;
    
    if (_index < 0) return;
    
}

@end
