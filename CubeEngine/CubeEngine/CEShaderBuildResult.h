//
//  CEShaderBuildResult.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShaderBuildResult : NSObject

@property (nonatomic, strong) NSDictionary *uniformDict;
@property (nonatomic, strong) NSDictionary *attributeDict;

@property (nonatomic, strong) NSString *vertexShader;
@property (nonatomic, strong) NSString *fragmentShader;

@end
