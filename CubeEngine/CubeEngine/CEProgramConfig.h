//
//  CEProgramConfig.h
//  CubeEngine
//
//  Created by chance on 5/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, CERenderMode) {
    CERenderModeSolid = 0,
    CERenderModeAlphaTest,
    CERenderModeTransparent,
};

@interface CEProgramConfig : NSObject <NSCopying>

@property (nonatomic, assign) CERenderMode renderMode;
@property (nonatomic, assign) int lightCount;
@property (nonatomic, assign) BOOL enableShadowMapping;
@property (nonatomic, assign) BOOL enableTexture;
@property (nonatomic, assign) BOOL enableNormalMapping;

- (BOOL)isEqualToConfig:(CEProgramConfig *)config;

@end
