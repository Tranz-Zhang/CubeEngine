//
//  CELight_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"
#import "CELightInfo.h"
#import "CERenderObject.h"


@interface CELight () {
    @protected
    CELightInfo *_lightInfo;
    CERenderObject *_renderObject;
    BOOL _enabled;
}

// light visual model
@property (nonatomic, readonly) CERenderObject *renderObject;

// light info
@property (nonatomic, readonly) CELightInfo *lightInfo;


@end

