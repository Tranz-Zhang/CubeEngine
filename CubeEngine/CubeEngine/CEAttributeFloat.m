//
//  CEAttributeFloat.m
//  CubeEngine
//
//  Created by chance on 9/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEAttributeFloat.h"

@implementation CEAttributeFloat

//- (void)setAttribute:(CEVBOAttribute *)attribute {
//    if (attribute.primaryCount != 1) {
//        CEError("Fail to set attribute:%@", CEVBOAttributeNameString(attribute.name));
//        return;
//    }
//    [super setAttribute:attribute];
//}

- (NSString *)dataType {
    return @"float";
}

@end
