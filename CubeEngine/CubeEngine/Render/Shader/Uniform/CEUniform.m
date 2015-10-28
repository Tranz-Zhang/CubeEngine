//
//  CEUniform.m
//  CubeEngine
//
//  Created by chance on 9/7/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniform.h"
#import "CEUniform_privates.h"

@implementation CEUniform

- (instancetype)initWithName:(NSString *)name{
    self = [super init];
    if (self) {
        _name = [name copy];
        _index = -1;
    }
    return self;
}


- (BOOL)setupIndexWithProgram:(CEProgram *)program {
    _index = [program uniformIndex:self.name];
    return _index >= 0;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"uniform %@ %@(%d)", [self dataType], self.name, _index];
}

- (NSString *)dataType {
    return @"unknown";
}

@end
