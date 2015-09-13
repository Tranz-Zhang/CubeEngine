//
//  CEDefines.h
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#ifndef CubeEngine_CEDefines_h
#define CubeEngine_CEDefines_h

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



#endif
