//
//  CEShaderStruct.m
//  CubeEngine
//
//  Created by chance on 8/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderStruct.h"
#import "CEShaderStruct_privates.h"

@implementation CEShaderStruct

//+ (instancetype)structWithName:(NSString *)name {
//    if (!name.length) {
//        return nil;
//    }
//    return [[[self class] alloc] initWithName:name];
//}


- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = [name copy];
    }
    return self;
}


- (NSString *)declaration {
    return [NSString stringWithFormat:@"%@ %@;", [[self class] structName], _name];
}


+ (NSString *)structName {
    NSAssert(false, @"Must implemented by subclass");
    return nil;
}

+ (NSString *)structDeclaration {
    NSAssert(false, @"Must implemented by subclass");
    return nil;
}


@end



