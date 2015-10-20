//
//  CEObjFileInfo.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModelInfo.h"

@implementation CEModelInfo

- (BOOL)isEqual:(CEModelInfo *)other {
    if (other == self) {
        return YES;
    } else {
        return _modelID == other.modelID;
    }
}


- (NSUInteger)hash {
    return _modelID;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MODEL%08X", _modelID];
}


@end
