//
//  CELight.h
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"

@interface CELight : CEObject {
    GLKVector3 _lightColorV3;
    GLKVector3 _ambientColorV3;
}

+ (NSUInteger)maxLightCount;
+ (void)setMaxLightCount:(NSInteger)maxLightCount;

@property (nonatomic, copy) UIColor *lightColor; // default is withte
@property (nonatomic, copy) UIColor *ambientColor; // default is 0.2*White


@end
