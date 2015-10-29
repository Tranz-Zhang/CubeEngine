//
//  CEImageConverter.m
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEImageConverter.h"

@implementation CEImageConverter

+ (void)convertImageTo16Bits565:(CEImageDecodeResult *)result {
    if (result.format != GL_RGB || result.internalFormat != GL_RGB) {
        CEError("WARNING:Fail to convert png 16bits RGB565");
        return;
    }
    size_t pixelCount = result.width * result.height;
    size_t bufferSize = pixelCount * 2;
    unsigned short * pixelBuffer = (unsigned short *)malloc(bufferSize);
    unsigned char * oldPixelBuffer = (unsigned char *)result.data.bytes;
    for (int i = 0; i < pixelCount; i++) {
        uint32_t idx = i * 3;
        pixelBuffer[i] = ((oldPixelBuffer[idx]       >> 3) << 11 |
                          (oldPixelBuffer[idx + 1]   >> 2) << 5  |
                          oldPixelBuffer[idx + 2]   >> 3);
    }
    result.bytesPerPixel = 2;
    result.texelType = GL_UNSIGNED_SHORT_5_6_5;
    result.data = [NSData dataWithBytesNoCopy:pixelBuffer length:bufferSize];
}


+ (void)convertImageTo16Bits5551:(CEImageDecodeResult *)result {
    if (result.format != GL_RGBA || result.internalFormat != GL_RGBA) {
        CEError("WARNING:Fail to convert png 16bits GL_RGBA5551");
        return;
    }
    size_t pixelCount = result.width * result.height;
    size_t bufferSize = pixelCount * 2;
    unsigned short * pixelBuffer = (unsigned short *)malloc(bufferSize);
    unsigned char * oldPixelBuffer = (unsigned char *)result.data.bytes;
    for (int i = 0; i < pixelCount; i++) {
        uint32_t idx = i * 4;
        pixelBuffer[i] = ((oldPixelBuffer[idx]       >> 3) << 11 |
                          (oldPixelBuffer[idx + 1]   >> 3) << 6  |
                          (oldPixelBuffer[idx + 2]   >> 3) << 1  |
                          oldPixelBuffer[idx + 3]   >> 7);
    }
    result.bytesPerPixel = 2;
    result.texelType = GL_UNSIGNED_SHORT_5_5_5_1;
    result.data = [NSData dataWithBytesNoCopy:pixelBuffer length:bufferSize];
}


+ (void)convertImageTo16Bits4444:(CEImageDecodeResult *)result {
    if (result.format != GL_RGBA || result.internalFormat != GL_RGBA) {
        CEError("WARNING:Fail to convert png 16bits GL_RGBA4444");
        return;
    }
    size_t pixelCount = result.width * result.height;
    size_t bufferSize = pixelCount * 2;
    unsigned short * pixelBuffer = (unsigned short *)malloc(bufferSize);
    unsigned char * oldPixelBuffer = (unsigned char *)result.data.bytes;
    for (int i = 0; i < pixelCount; i++) {
        uint32_t idx = i * 4;
        pixelBuffer[i] = ((oldPixelBuffer[idx]       >> 4) << 12 |
                          (oldPixelBuffer[idx + 1]   >> 4) << 8  |
                          (oldPixelBuffer[idx + 2]   >> 4) << 4  |
                          oldPixelBuffer[idx + 3]   >> 4);
    }
    result.bytesPerPixel = 2;
    result.texelType = GL_UNSIGNED_SHORT_5_5_5_1;
    result.data = [NSData dataWithBytesNoCopy:pixelBuffer length:bufferSize];
}


@end
