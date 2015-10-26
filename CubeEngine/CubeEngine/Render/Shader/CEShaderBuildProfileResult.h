//
//  CEShaderBuildContainer.h
//  CubeEngine
//
//  Created by chance on 9/2/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

// use for cache template build info
@interface CEShaderBuildProfileResult : NSObject

@property (nonatomic, copy) NSString *shaderString;
@property (nonatomic, readonly) NSMutableArray *structs;
@property (nonatomic, readonly) NSMutableArray *attributes;
@property (nonatomic, readonly) NSMutableArray *uniforms;
@property (nonatomic, readonly) NSMutableArray *varyings;

@end
