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

#import "Utils.h"
#import "NSData+GLKit.h"

extern NSString *kAppPath;
extern NSString *kEngineProjectDirectory;
extern NSString *kResourcesDirectory;


#endif


#import "CECommon.h"
#import "CECommon_privates.h"

#define kToolVersion 1

#define ENABLE_INCREMENTAL_UPDATE 1
#define ENABLE_TRIANGLE_STRIP 1

#endif
