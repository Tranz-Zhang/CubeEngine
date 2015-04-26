//
//  Common.h
//  CubeEngineDev
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#ifndef CubeEngineDev_Common_h
#define CubeEngineDev_Common_h

GLKVector3 Vec3WithColor(UIColor *color);

GLKVector4 Vec4WithColor(UIColor *color);

UIColor *ColorWithVec3(GLKVector3 vec3);

UIColor *ColorWithVec4(GLKVector4 vec4);

// Axis Color
UIColor *ColorOfAxisX();
UIColor *ColosOfAxisY();
UIColor *ColosOfAxisZ();

#endif
