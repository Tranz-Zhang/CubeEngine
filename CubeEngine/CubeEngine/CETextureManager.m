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

@interface CETextureManager () <CEResourceDataProcessProtocol> {
    // runtime
    NSMutableArray *_textureUnitLRUQueue;
    NSMutableDictionary *_textureUnitBindingDict;
    NSMutableDictionary *_textureBufferDict;
    
    // resource loading
    NSMutableDictionary *_textureConfigDict;
}

@end


@implementation CETextureManager

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
        _textureConfigDict = [NSMutableDictionary dictionary];
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
    
    [[CEResourceManager sharedManager] loadResourceDataWithIDs:textureInfoDict.allKeys processDelegate:self completion:^(NSDictionary *resourceDataDict) {
        // generate texture buffer
        NSMutableDictionary *textureBufferDict = [NSMutableDictionary dictionary];
        [resourceDataDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *resourceID, NSData *textureData, BOOL *stop) {
            CETextureInfo *info = textureInfoDict[resourceID];
            CETextureBufferConfig *config = _textureConfigDict[resourceID];
            if (info && config) {
                CETextureBuffer *textureBuffer = [[CETextureBuffer alloc] initWithConfig:config resourceID:info.textureID data:textureData];
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


// CEResourceDataProcessProtocol
- (NSDictionary *)processDataDict:(NSDictionary *)resourceDataDict {
    NSMutableDictionary *unpackDataDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *configDict = [NSMutableDictionary dictionary];
    [resourceDataDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *resourceID, NSData *textureData, BOOL *stop) {
        // unpack png data
        CEPNGUnpackResult *result = [[CEPNGUnpacker defaultPacker] unpackPNGData:textureData];
        // [CEPNGUnpacker convertPNGTo16Bits4444:result];
        unpackDataDict[resourceID] = result.data;
        
        CETextureBufferConfig *config = [CETextureBufferConfig new];
        config.width = result.width;
        config.height = result.height;
        config.format = result.format;
        config.internalFormat = result.internalFormat;
        config.texelType = result.texelType;
        config.wrap_s = GL_REPEAT;
        config.wrap_t = GL_REPEAT;
        configDict[resourceID] = config;
        
    }];
    @synchronized(_textureConfigDict) {
        [_textureConfigDict addEntriesFromDictionary:configDict];
    }
    return unpackDataDict.copy;
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
        int32_t lastBindUnit = [_textureUnitBindingDict[@(textureID)] intValue];
        CETextureBuffer *textureBuffer = _textureBufferDict[preparingID];
        [textureBuffer loadBufferToUnit:lastBindUnit];
        return lastBindUnit;
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
            [textureBuffer loadBufferToUnit:lastBindUnit];
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



