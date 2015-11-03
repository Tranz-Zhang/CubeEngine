//
//  TextureDataPacker.m
//  CubeEngine
//
//  Created by chance on 10/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "TextureDataPacker.h"
#import "BaseDataPacker_private.h"
#import "PVRTextureConverter.h"


@implementation TextureDataPacker

- (NSString *)packTextureDataWithInfo:(TextureInfo *)textureInfo {
    NSData *imageData = nil;
    NSString *pvrImagePath = nil;
    if (CONVERT_TEXTURE_TO_PVR && textureInfo.format != CETextureFormatPVR) { // Convert image to pvr
        pvrImagePath = [[PVRTextureConverter defaultConverter] convertImageAtPath:textureInfo.filePath
                                                                             generateMipmap:YES];
        imageData = [NSData dataWithContentsOfFile:pvrImagePath];
        textureInfo.format = CETextureFormatPVR;
    }
    if (!imageData) {
        imageData = [NSData dataWithContentsOfFile:textureInfo.filePath];
    }
    if (!imageData.length) {
        return nil;
    }
    
    NSString *resultPath = [self writeData:@{@(textureInfo.resourceID) : imageData}];
    // remove pvr temp file
    if (pvrImagePath) {
        [[NSFileManager defaultManager] removeItemAtPath:pvrImagePath error:nil];
    }
    return resultPath;
}


- (NSString *)targetFileDirectory {
    return kTextureDirectory;
}


@end

