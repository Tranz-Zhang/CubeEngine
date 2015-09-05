//
//  CEShaderBuildResult.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderVariableInfo.h"

@interface CEShaderInfo : NSObject

@property (nonatomic, readonly) NSDictionary *attributeDict; // @{"Name" : CEShaderVariableInfo};
@property (nonatomic, readonly) NSDictionary *uniformsDict;  // @{"Name" : CEShaderVariableInfo};
@property (nonatomic, readonly) NSString *vertexShader;
@property (nonatomic, readonly) NSString *fragmentShader;

@end
