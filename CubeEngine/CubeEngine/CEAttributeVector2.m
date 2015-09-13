//
//  CEAttributeVector2.m
//  CubeEngine
//
//  Created by chance on 9/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEAttributeVector2.h"

@implementation CEAttributeVector2

//- (void)setAttribute:(CEVBOAttribute *)attribute {
//    if (attribute.primaryCount != 2) {
//        CEError("Fail to set attribute:%@", CEVBOAttributeNameString(attribute.name));
//        return;
//    }
//    [super setAttribute:attribute];
//}

- (NSString *)dataType {
    return @"vec2";
}

@end
