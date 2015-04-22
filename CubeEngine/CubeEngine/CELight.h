//
//  CELight.h
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"

typedef NS_ENUM(NSInteger, CELightType) {
    CEDirectionLight = 1,
    CEDotLight,
    CESpotLight,
};

@interface CELight : CEObject

+ (instancetype)lightWithType:(int)lightType;

@end
