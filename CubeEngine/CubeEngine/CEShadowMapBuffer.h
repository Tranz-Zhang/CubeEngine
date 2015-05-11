//
//  CEShadowMapBuffer.h
//  CubeEngine
//
//  Created by chance on 5/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShadowMapBuffer : NSObject

@property (nonatomic, readonly) GLuint textureId;
@property (nonatomic, readonly) CGSize textureSize;
@property (nonatomic, readonly, getter=isReady) BOOL ready;

- (instancetype)initWithTextureSize:(CGSize)textureSize;

- (BOOL)setupBuffer;

// bind shadow map framebuffer and texture
- (void)prepareBuffer;

@end


