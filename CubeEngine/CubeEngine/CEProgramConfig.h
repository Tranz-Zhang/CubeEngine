//
//  CEProgramConfig.h
//  CubeEngine
//
//  Created by chance on 5/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEProgramConfig : NSObject <NSCopying>

@property (nonatomic, assign) int lightCount;
@property (nonatomic, assign) BOOL shadowMappingCount;
@property (nonatomic, assign) BOOL enableTexture;
@property (nonatomic, assign) BOOL enableNormalMapping;

- (BOOL)isEqualToConfig:(CEProgramConfig *)config;

@end
