//
//  CETextureManager.m
//  CubeEngine
//
//  Created by chance on 10/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CETextureManager.h"
#import "CEResourceManager.h"
#import "CEPNGUnpacker.h"

@implementation CETextureManager {
    NSMutableArray *_textureUnitLRUQueue;
    NSMutableDictionary *_textureUnitBindingDict;
    NSMutableDictionary *_textureBufferDict;
}


#pragma mark - environment params
+ (GLint)maxTextureUnitCount {
    static GLint sMaxTextureUnitCount = 0;
    if (!sMaxTextureUnitCount) {
        glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &sMaxTextureUnitCount);
    }
    return sMaxTextureUnitCount;
}


+ (GLint)maxTextureSize {
    static GLint sMaxTextureSize = 0;
    if (!sMaxTextureSize) {
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, &sMaxTextureSize);
    }
    return sMaxTextureSize;
}


+ (instancetype)sharedManager {
    static CETextureManager *_shareInstance;
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[[self class] alloc] init];
        });
    }
    return _shareInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _textureUnitLRUQueue = [NSMutableArray arrayWithCapacity:[CETextureManager maxTextureUnitCount]];
        _textureBufferDict = [NSMutableDictionary dictionary];
        _textureUnitBindingDict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)loadTextureWithInfos:(NSArray *)textureInfos completion:(CETextureLoadCompletion)completion {
    CGFloat maxTextureSize = [CETextureManager maxTextureSize];
    NSMutableDictionary *textureInfoDict = [NSMutableDictionary dictionary]; // @{@(resourceID) : CETextureInfo}
    for (CETextureInfo *textureInfo in textureInfos) {
        if (textureInfo.textureSize.width <= maxTextureSize &&
            textureInfo.textureSize.height <= maxTextureSize) {
            textureInfoDict[@(textureInfo.textureID)] = textureInfo;
        }
    }
    [[CEResourceManager sharedManager] loadResourceDataWithIDs:textureInfoDict.allKeys completion:^(NSDictionary *resourceDataDict) {
        // generate texture buffer
        NSMutableDictionary *textureBufferDict = [NSMutableDictionary dictionary];
        [resourceDataDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *resourceID, NSData *textureData, BOOL *stop) {
            CETextureInfo *info = textureInfoDict[resourceID];
            if (info) {
                CEPNGUnpackResult *result = [[CEPNGUnpacker defaultPacker] unpackPNGData:textureData];
                CETextureBufferConfig *config = [CETextureBufferConfig new];
                config.width = result.width;
                config.height = result.height;
                config.format = result.format;
                config.internalFormat = result.internalFormat;
                config.texelType = result.texelType;
                CETextureBuffer *textureBuffer = [[CETextureBuffer alloc] initWithConfig:config resourceID:info.textureID data:result.data];
//                CETextureBuffer *textureBuffer = [[CETextureBuffer alloc] initWithSize:info.textureSize config:nil resourceID:info.textureID data:textureData];
                textureBufferDict[resourceID] = textureBuffer;
            }
        }];
        @synchronized(self) {
            [_textureBufferDict addEntriesFromDictionary:textureBufferDict];
        }
        if (completion) {
            completion([NSSet setWithArray:textureBufferDict.allKeys]);
        }
    }];
}


- (void)unloadTextureWithID:(uint32_t)textureID fromMemory:(BOOL)removeFromMemory {
    @synchronized(self) {
        [_textureUnitLRUQueue removeObject:@(textureID)];
        [_textureBufferDict removeObjectForKey:@(textureID)];
    }
    if (removeFromMemory) {
        [[CEResourceManager sharedManager] unloadResourceDataWithID:textureID];
    }
}


- (int32_t)prepareTextureWithID:(uint32_t)textureID {
    NSNumber *preparingID = @(textureID);
    if (_textureUnitBindingDict[preparingID]) { // already loaded
        @synchronized(self) {
            [_textureUnitLRUQueue removeObjectAtIndex:[_textureUnitLRUQueue indexOfObject:preparingID]];
            [_textureUnitLRUQueue insertObject:preparingID atIndex:0];
        }
        return [_textureUnitBindingDict[@(textureID)] intValue];
    }
    
    if (_textureBufferDict[preparingID]) { // load into new unit
        CETextureBuffer *textureBuffer = _textureBufferDict[preparingID];
        if (!textureBuffer.isReady && ![textureBuffer setupBuffer]) {
            CEPrintf("Fail to setup texture Buffer");
            return 0;
        }
        
        int32_t lastBindUnit = -1;
        @synchronized(self) {
            if (_textureUnitLRUQueue.count >= [CETextureManager maxTextureUnitCount]) {
                NSNumber *lastTextureID = [_textureUnitLRUQueue lastObject];
                [_textureUnitLRUQueue removeLastObject];
                [_textureUnitLRUQueue insertObject:preparingID atIndex:0];
                lastBindUnit = [_textureUnitBindingDict[lastTextureID] intValue];
                [_textureUnitBindingDict removeObjectForKey:lastTextureID];
                _textureUnitBindingDict[preparingID] = @(lastBindUnit);
                
            } else {
                lastBindUnit = (int32_t)_textureUnitLRUQueue.count;
                _textureUnitBindingDict[preparingID] = @(lastBindUnit);
                [_textureUnitLRUQueue insertObject:preparingID atIndex:0];
            }
        }
        if (lastBindUnit >= 0) {
            [textureBuffer loadBufferToIndex:lastBindUnit];
            return lastBindUnit;
            
        } else {
            CEPrintf("Fail to get last binded texture unit\n");
        }
        
    } else {
        CEPrintf("Not texture found for id: %X\n", textureID);
    }
    return 0;
}





@end



