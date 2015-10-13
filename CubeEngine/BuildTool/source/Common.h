//
//  Common.h
//  CubeEngine
//
//  Created by chance on 9/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#ifndef CubeEngine_Common_h
#define CubeEngine_Common_h

#ifdef __OBJC__
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#endif

extern NSString *kAppPath;
#import "CECommon_privates.h"

#define kBaseModelID    0x10000000
#define kBaseMeshID     0x20000000
#define kBaseMaterialID 0x30000000
#define kBaseTextureID  0x40000000

#endif
