//
//  CEAttributeVector4.m
//  CubeEngine
//
//  Created by chance on 9/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEAttributeVector4.h"

@implementation CEAttributeVector4

- (void)setAttribute:(CEVBOAttribute *)attribute {
    if (attribute.primaryCount != 4) {
        return;
    }
    [super setAttribute:attribute];
}

- (NSString *)dataType {
    return @"vec4";
}

@end

