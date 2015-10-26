//
//  CubeEngine.h
//  CubeEngine
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#ifndef CubeEngine_h
#define CubeEngine_h

#ifdef __OBJC__


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

// API
#import "CECommon.h"

#import "CEObject.h"
#import "CEModel.h"
#import "CEMaterial.h"
#import "CECamera.h"

// lights
#import "CEShadowLight.h"
#import "CEDirectionalLight.h"
#import "CEPointLight.h"
#import "CESpotLight.h"

#import "CEScene.h"
#import "CEViewController.h"
#import "CEModelLoader.h"

#endif // end of __OBJC__


#define CUBE_ENGINE_VERSION @"0.6.0"

#endif // end of CubeEngine_h
