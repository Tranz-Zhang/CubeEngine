//
//  CERenderConfig.h
//  CubeEngine
//
//  Created by chance on 9/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, CERenderType) {
    CERenderTypeSolid = 0,
    CERenderTypeAlphaTest,
    CERenderTypeTransparent,
};


@interface CERenderConfig : NSObject <NSCopying>

@property (nonatomic, assign) CERenderType renderType;
@property (nonatomic, assign) CELightType lightType;
@property (nonatomic, assign) BOOL enableShadowMapping;
@property (nonatomic, assign) BOOL enableTexture;
@property (nonatomic, assign) BOOL enableNormalMapping;

- (BOOL)isEqualToConfig:(CERenderConfig *)config;

@end
