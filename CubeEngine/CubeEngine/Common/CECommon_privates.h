//
//  CECommon_privates.h
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#ifndef CubeEngine_CEDefines_h
#define CubeEngine_CEDefines_h

#import "NSData+GLKit.h"

// shader string
#define CE_SHADER_STRING(text) @ #text

// buffer offset
#define CE_BUFFER_OFFSET(i) ((char *)NULL + (i))


typedef NS_ENUM(NSInteger, CELightType) {
    CELightTypeNone = 0,
    CELightTypeDirectional = 1,
    CELightTypePoint,
    CELightTypeSpot,
};

typedef NS_ENUM(NSInteger, CETextureFormat) {
    CETextureFormatUnknown = 0,
    CETextureFormatPNG,
    CETextureFormatJPEG,
    CETextureFormatPVR,
};


typedef struct _CEPVRTexHeader
{
    uint32_t headerLength;
    uint32_t height;
    uint32_t width;
    uint32_t numMipmaps;
    uint32_t flags;
    uint32_t dataLength;
    uint32_t bpp;
    uint32_t bitmaskRed;
    uint32_t bitmaskGreen;
    uint32_t bitmaskBlue;
    uint32_t bitmaskAlpha;
    uint32_t pvrTag;
    uint32_t numSurfs;
} CEPVRTexHeader;



#endif
