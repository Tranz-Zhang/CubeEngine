//
//  CETextureManager.h
//  CubeEngine
//
//  Created by chance on 10/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CETextureInfo.h"
#import "CETextureBuffer.h"

typedef void(^CETextureLoadCompletion)(NSSet *loadedTextureIds);

@interface CETextureManager : NSObject

+ (instancetype)sharedManager;

+ (GLint)maxTextureUnitCount;
+ (GLint)maxTextureSize;


/**
 load texture resource in to memory
 
 @param textureInfos array of CETextureInfo
 @param completion called after completion, returns the loaded texture ids
 */
- (void)loadTextureWithInfos:(NSArray *)textureInfos completion:(CETextureLoadCompletion)completion;


/**
 remove texture data from memory
 */
- (void)unloadTextureWithID:(uint32_t)textureID fromMemory:(BOOL)removeFromMemory;


/**
 setup texture for rendering
 @return texture unit index if successfully load the specify texture into texture unit,
         returns -1 when failed.
 */
- (int32_t)prepareTextureWithID:(uint32_t)textureID;


/**
 generate a blank texture buffer, normally for offscreen drawing
 */
- (CETextureBuffer *)generateTextureBufferWithSize:(CGSize)textureSize
                                            config:(CETextureBufferConfig *)config;


@end

