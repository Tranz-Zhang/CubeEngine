//
//  CEShadowMapRenderer.h
//  CubeEngine
//
//  Created by chance on 5/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShadowMapRenderer_DEPRECATED : NSObject

@property (nonatomic, assign) GLKMatrix4 lightVPMatrix;

- (void)renderShadowMapWithObjects:(NSArray *)objects;

@end
