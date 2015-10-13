//
//  TextureDataPacker.m
//  CubeEngine
//
//  Created by chance on 10/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "TextureDataPacker.h"
#import "BaseDataPacker_private.h"

@implementation TextureDataPacker

- (BOOL)packTextureDataWithInfo:(TextureInfo *)textureInfo {
    NSData *imageData = [NSData dataWithContentsOfFile:textureInfo.filePath];
    if (!imageData.length) {
        return NO;
    }
    return [self writeData:@{@(textureInfo.resourceID) : imageData}];
}


- (NSString *)targetFileDirectory {
    return kTextureDirectory;
}


@end
