//
//  CEModel.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModel.h"
#import "CEModel_Rendering.h"
#import "CETextureManager.h"

@implementation CEModel

- (instancetype)initWithName:(NSString *)name renderObjects:(NSArray *)renderObjects {
    self = [super init];
    if (self) {
        _name = [name copy];
        _renderObjects = renderObjects;
    }
    return self;
}


- (void)dealloc {
    
}


- (NSString *)debugDescription {
    return _name;
}

#pragma mark - Setters & Getters
- (void)setMipmapQuality:(CETextureMipmapQuality)mipmapQuality {
    if (_mipmapQuality == mipmapQuality) {
        return;
    }
    _mipmapQuality = mipmapQuality;
    // update texture buffers in renderObjects
    CETextureManager *textureManager = [CETextureManager sharedManager];
    for (CERenderObject *renderObject in _renderObjects) {
        if (renderObject.material.diffuseTextureID) {
            CETextureBuffer *textureBuffer = [textureManager textureBufferWithID:renderObject.material.diffuseTextureID];
            [self updateTextureBuffer:textureBuffer withQuality:mipmapQuality];
        }
        if (renderObject.material.normalTextureID) {
            CETextureBuffer *textureBuffer = [textureManager textureBufferWithID:renderObject.material.normalTextureID];
            [self updateTextureBuffer:textureBuffer withQuality:mipmapQuality];
        }
        if (renderObject.material.specularTextureID) {
            CETextureBuffer *textureBuffer = [textureManager textureBufferWithID:renderObject.material.specularTextureID];
            [self updateTextureBuffer:textureBuffer withQuality:mipmapQuality];
        }
    }

}


- (void)updateTextureBuffer:(CETextureBuffer *)textureBuffer
                withQuality:(CETextureMipmapQuality)mipmapQuality {
    CETextureBufferConfig *config = textureBuffer.config;
    switch (mipmapQuality) {
        case CETextureMipmapNone:
            config.enableMipmap = NO;
            config.enableAnisotropicFiltering = NO;
            config.mipmapLevel = 1;
            config.mag_filter = GL_LINEAR;
            config.min_filter = GL_LINEAR;
            break;
            
        case CETextureMipmapLow:
            config.enableMipmap = YES;
            config.enableAnisotropicFiltering = NO;
            config.mipmapLevel = 3;
            config.mag_filter = GL_NEAREST;
            config.min_filter = GL_NEAREST_MIPMAP_NEAREST;
            break;
            
        case CETextureMipmapNormal:
            config.enableMipmap = YES;
            config.enableAnisotropicFiltering = NO;
            config.mipmapLevel = 3;
            config.mag_filter = GL_LINEAR;
            config.min_filter = GL_NEAREST_MIPMAP_LINEAR;
            break;
            
        case CETextureMipmapHigh:
            config.enableMipmap = YES;
            config.enableAnisotropicFiltering = YES;
            config.mipmapLevel = 3;
            config.mag_filter = GL_LINEAR;
            config.min_filter = GL_NEAREST_MIPMAP_LINEAR;
            break;
            
        default:
            break;
    }
    [textureBuffer updateConfig:config];
}


#pragma mark - API

- (CEModel *)childWithName:(NSString *)modelName {
    for (CEModel *child in _childObjects) {
        if ([child.name isEqualToString:modelName]) {
            return child;
        }
    }
    // search child's child
    for (CEModel *child in _childObjects) {
        CEModel *childChild = [child childWithName:modelName];
        if (childChild) {
            return childChild;
        }
    }
    return nil;
}


#pragma mark - Wireframe
- (void)setShowAccessoryLine:(BOOL)showAccessoryLine {
    _showAccessoryLine = showAccessoryLine;
    for (CEModel *child in _childObjects) {
        child.showAccessoryLine = showAccessoryLine;
    }
}


- (void)setShowWireframe:(BOOL)showWireframe {
    if (showWireframe != _showWireframe) {
        _showWireframe = showWireframe;
    }
    for (CEModel *child in _childObjects) {
        child.showWireframe = showWireframe;
    }
}

@end


