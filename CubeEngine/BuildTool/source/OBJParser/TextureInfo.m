//
//  TextureInfo.m
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "TextureInfo.h"
#import "Common.h"

@implementation TextureInfo

+ (TextureInfo *)textureInfoWithFilePath:(NSString *)filePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    CETextureFormat format = [self textureFormatForFileAtPath:filePath];
    if (format == CETextureFormatUnknown) {
        return nil;
    }
    
    TextureInfo *info = [TextureInfo new];
    info.name = [filePath lastPathComponent];
    info.filePath = filePath;
    info.format = format;
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
    }
    
    return info;
}

+ (CETextureFormat )textureFormatForFileAtPath:(NSString *)filePath {
    if ([filePath hasSuffix:@".png"]) {
        return CETextureFormatPNG;
        
    } else if ([filePath hasSuffix:@".jpg"] || [filePath hasSuffix:@".jpeg"]) {
        return CETextureFormatJPEG;
        
    } else if ([filePath hasSuffix:@".pvr"]) {
        return CETextureFormatPVR;
        
    } else {
        return CETextureFormatUnknown;
    }
}


/*
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
        default:
            break;
    }
    return TextureFormatUnknown;
}
//*/


- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)setFilePath:(NSString *)filePath {
    if (![_filePath isEqualToString:filePath]) {
        _filePath = filePath;
        _resourceID = HashValueWithString(filePath);
    }
}


- (BOOL)isEqual:(TextureInfo *)other {
    if (other == self) {
        return YES;
    }else {
        return _resourceID && _resourceID == other.resourceID;;
    }
}


- (NSUInteger)hash {
    return _resourceID;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TEX[%08X] %.0fX%.0f PNG %s", _resourceID, _size.width, _size.height, _hasAlpha ? "-Alpha" : ""];
}

@end


