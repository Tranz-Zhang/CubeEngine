//
//  CETextureInfo.m
//  CubeEngine
//
//  Created by chance on 9/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CETextureInfo.h"

@implementation CETextureInfo

- (BOOL)isEqual:(CETextureInfo *)other {
    if (other == self) {
        return YES;
    } else {
        return _textureID == other.textureID;
    }
}


- (NSUInteger)hash {
    return _textureID;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"TEX%X", _textureID];
}


@end
