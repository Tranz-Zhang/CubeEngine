//
//  TextureInfo.m
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "TextureInfo.h"
#import "Common.h"

static uint32_t sNextResourceID = kBaseTextureID;

@implementation TextureInfo

+ (TextureInfo *)textureInfoWithFilePath:(NSString *)filePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    TextureInfo *info = [TextureInfo new];
    info.fileName = [filePath lastPathComponent];
    info.filePath = filePath;
    // get format
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *firstByte = [fileHandle readDataOfLength:1];
    info.format = [TextureInfo textureFormatImageData:firstByte];
    // get image size
    NSURL *imageFileURL = [NSURL fileURLWithPath:filePath];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    if (imageSource) {
        NSDictionary *options = @{(id)kCGImageSourceShouldCache : @NO};
        NSDictionary *imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        NSNumber *width = imageProperties[(id)kCGImagePropertyPixelWidth];
        NSNumber *height = imageProperties[(id)kCGImagePropertyPixelHeight];
        info.size = CGSizeMake(width.floatValue, height.floatValue);
        info.hasAlpha = [imageProperties[(id)kCGImagePropertyHasAlpha] boolValue];
        info.bitsPerPixel = [imageProperties[(id)kCGImagePropertyDepth] shortValue];
        
        // TODO: try to get image format from these properties...
    }
    
    return info;
}

+ (TextureFormat )textureFormatImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return TextureFormatJPEG;
        case 0x89:
            return TextureFormatPNG;
        case 0x47:
            return TextureFormatGIF;
        case 0x49:
        case 0x4D:
            return TextureFormatTIFF;
    }
    return TextureFormatUnknown;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _resourceID = sNextResourceID++;
    }
    return self;
}


@end
