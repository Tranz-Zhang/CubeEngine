//
//  CEAttributeVector3.m
//  CubeEngine
//
//  Created by chance on 9/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEAttributeVector3.h"

@implementation CEAttributeVector3

//- (void)setAttribute:(CEVBOAttribute *)attribute {
//    if (attribute.primaryCount != 3) {
//        CEError("Fail to set attribute:%@", CEVBOAttributeNameString(attribute.name));
//        return;
//    }
//    [super setAttribute:attribute];
//}

- (NSString *)dataType {
    return @"vec3";
}

@end
