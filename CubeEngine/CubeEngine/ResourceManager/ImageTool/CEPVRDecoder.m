//
//  CEPVRDecoder.m
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEPVRDecoder.h"

#define CE_PVR_TEXTURE_FLAG_TYPE_MASK	0xff

static char gCEPVRTexIdentifier[4] = "PVR!";

enum
{
    kCEPVRTextureFlagTypePVRTC_2 = 24,
    kCEPVRTextureFlagTypePVRTC_4 = 25,
};


@implementation CEPVRDecoder

- (CEImageDecodeResult *)decodeImageData:(NSData *)imageData {
#if GL_IMG_texture_compression_pvrtc
    CEPVRTexHeader *header = NULL;
    header = (CEPVRTexHeader *)imageData.bytes;
    // check pvr tag
    uint32_t pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
    if (gCEPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
        gCEPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
        gCEPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
        gCEPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff)) {
        return nil;
    }
    // check pvr format
    uint32_t flags = CFSwapInt32LittleToHost(header->flags);
    uint32_t formatFlags = flags & CE_PVR_TEXTURE_FLAG_TYPE_MASK;
    if (formatFlags != kCEPVRTextureFlagTypePVRTC_2 &&
        formatFlags != kCEPVRTextureFlagTypePVRTC_4) {
        return nil;
    }
    
    CEImageDecodeResult *result = [[CEImageDecodeResult alloc] init];
    if (formatFlags == kCEPVRTextureFlagTypePVRTC_2) {
        result.format =         GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
        result.internalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
        
    } else if (formatFlags == kCEPVRTextureFlagTypePVRTC_4) {
        result.format =         GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
        result.internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
    }
    result.width = CFSwapInt32LittleToHost(header->width);
    result.height = CFSwapInt32LittleToHost(header->height);
//    BOOL hasAlpha = CFSwapInt32LittleToHost(header->bitmaskAlpha);
    result.bytesPerPixel = CFSwapInt32LittleToHost(header->bpp);
    result.texelType = GL_UNSIGNED_BYTE;
    result.data = imageData;
    
    return result;
#else
    return nil;
#endif
}


@end


