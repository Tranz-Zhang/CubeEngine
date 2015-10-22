//
//  CEShaderBuilder.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderInfo.h"

//typedef NS_ENUM(int, CEShaderRenderType) {
//    CEShaderRenderTypeSolid = 0,
//    CEShaderRenderTypeAlpha,
//    CEShaderRenderTypeTransparent,
//};


@interface CEShaderBuilder : NSObject

- (void)startBuildingNewShader;

- (void)setMaterialType:(CEMaterialType)materialType;
- (void)enableLightWithType:(CELightType)lightType;
- (void)enableNormalLightWithType:(CELightType)lightType;
- (void)enableTexture:(BOOL)enabled;
- (void)enableShadowMap:(BOOL)enabled;

- (CEShaderInfo *)build;

@end

