//
//  CECommon.h
//  CubeEngine
//
//  Created by chance on 10/12/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#ifndef CubeEngine_CECommon_h
#define CubeEngine_CECommon_h


typedef NS_ENUM(int, CEMaterialType) {
    CEMaterialSolid = 0,
    CEMaterialAlphaTested,
    CEMaterialTransparent,
};


typedef NS_ENUM(int, CETextureMipmapQuality) {
    CETextureMipmapNone = 0, // disable mipmap
    CETextureMipmapLow,
    CETextureMipmapNormal,
    CETextureMipmapHigh,
};


#endif
