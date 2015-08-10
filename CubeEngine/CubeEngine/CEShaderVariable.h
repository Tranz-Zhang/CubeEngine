//
//  CEShaderVariable.h
//  CubeEngine
//
//  Created by chance on 8/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef NS_ENUM(int, CEShaderDataPrecision) {
    CELowp,
    CEMediump,
    CEHighp,
};


@interface CEShaderVariable : NSObject {
    GLint _index;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) CEShaderDataPrecision precision;

- (instancetype)initWithName:(NSString *)name precision:(CEShaderDataPrecision)precision;

@end


/*
 typedef NS_ENUM(int, CEShaderDataType) {
 CEGLSL_void = 0,
 CEGLSL_bool = 1,
 CEGLSL_int,
 CEGLSL_float,
 
 CEGLSL_vec2,    // float vector
 CEGLSL_vec3,
 CEGLSL_vec4,
 
 CEGLSL_bvec2,   // boolean vector
 CEGLSL_bvec3,
 CEGLSL_bvec4,
 
 CEGLSL_ivec2,   // signed integer vector
 CEGLSL_ivec3,
 CEGLSL_ivec4,
 
 CEGLSL_mat2,    // float matrix
 CEGLSL_mat3,
 CEGLSL_mat4,
 
 CEGLSL_sample2D,    // 2D texture
 CEGLSL_sampleCube,  // Cube mapped texture
 
 CEShaderDataTypeCount,
 };
 //*/