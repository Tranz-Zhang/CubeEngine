//
//  CEResourceManager.m
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <sys/stat.h>

#import "CEResourceManager.h"
#import "CEResourceDefines.h"
#import "CEDB.h"
#import "CEResourceDataInfo.h"

#define kMaxMemoryCacheSize 50 //MB

#define kBaseRuntimeResourceID 0xF0000000
#define kMaxRuntimeResourceID 0xFFFFFFFF
static NSMutableSet *sRuntimeResourceIDs;
static uint32_t sNextRuntimeResourceID = kBaseRuntimeResourceID;

@interface CEResourceCache : NSObject

@property (nonatomic, assign) uint32_t resourceID;
@property (nonatomic, strong) NSData *cachedData;

@end

@implementation CEResourceCache

@end


@implementation CEResourceManager {
    dispatch_queue_t _resourceQueue;
    // resources
    NSString *_bundlePath;
    CEDatabase *_db;
    CEDatabaseContext *_dbContext;
    
    // LRU
    NSMutableArray *_resourceCacheQueue; // array of resource id
    NSMutableDictionary *_resourceCacheDict; // @{@(resourceID) : CEResourceCache}
    uint32_t _currentCacheSize;
    uint32_t _maxCacheSize;
}

#pragma mark - Runtime Resource ID
+ (uint32_t)generateRuntmeResourceID {
    if (!sRuntimeResourceIDs) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sRuntimeResourceIDs = [NSMutableSet set];
        });
    }
    if (sRuntimeResourceIDs.count < 0x0FFFFFFF) {
        do {
            sNextRuntimeResourceID++;
            if (sNextRuntimeResourceID == 0) {
                sNextRuntimeResourceID = kBaseRuntimeResourceID;
            }
            
        } while ([sRuntimeResourceIDs containsObject:@(sNextRuntimeResourceID)]);
        [sRuntimeResourceIDs addObject:@(sNextRuntimeResourceID)];
        return sNextRuntimeResourceID;
        
    } else {
        return 0;
    }
}


+ (void)recycleRuntimeResourceID:(uint32_t)resourceID {
    [sRuntimeResourceIDs removeObject:@(sNextRuntimeResourceID)];
}


+ (instancetype)sharedManager {
    static CEResourceManager *_shareInstance;
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
        _resourceQueue = dispatch_queue_create("com.cube-engine.resourceManager", DISPATCH_QUEUE_CONCURRENT);
        _bundlePath = [[NSBundle mainBundle] bundlePath];
        _maxCacheSize = kMaxMemoryCacheSize * 1024 * 1024;
        NSString *configDir = [_bundlePath stringByAppendingPathComponent:kConfigDirectory];
        if ([[NSFileManager defaultManager] fileExistsAtPath:configDir]) {
            _db = [CEDatabase databaseWithName:kResourceDataDBName inPath:configDir];
            _dbContext = [CEDatabaseContext contextWithTableName:kDBTableResourceData
                                                           class:[CEResourceDataInfo class]
                                                      inDatabase:_db];
        }
        
    }
    return self;
}


- (void)loadResourceDataWithIDs:(NSArray *)resourceIDs completion:(CEResourceDataLoadedCompletion)completion {
    dispatch_async(_resourceQueue, ^{
        // try to load from cached data
        NSMutableSet *resourcesToLoad = [NSMutableSet setWithArray:resourceIDs];
        NSMutableDictionary *loadedDataDict = [NSMutableDictionary dictionary];
        for (NSNumber *resourceID in resourceIDs) {
            NSData *cachedData = _resourceCacheDict[resourceID];
            if (cachedData) {
                CEPrintf("Load fast cache for resource: %X\n", resourceID.unsignedIntValue);
                loadedDataDict[resourceID] = cachedData;
                [resourcesToLoad removeObject:resourceID];
                
                // LRU: move resouceID to first
                [_resourceCacheQueue removeObject:resourceID];
                [_resourceCacheQueue insertObject:resourceID atIndex:0];
            }
        }
        
        // load from disk
        if (resourcesToLoad.count) {
            NSDictionary *diskDataDict = [self loadDataWithResourceIDs:resourcesToLoad];
            // add to local cache
            [diskDataDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *resourceID, NSData *data, BOOL *stop) {
                if (!_resourceCacheDict[resourceID]) {
                    _resourceCacheDict[resourceID] = data;
                    [_resourceCacheQueue insertObject:resourceID atIndex:0];
                    _currentCacheSize += data.length;
                }
            }];
            [loadedDataDict addEntriesFromDictionary:diskDataDict];
        }
        
        if (completion) {
            completion(loadedDataDict.copy);
        }
        [self checkMemorySize];
    });
}


- (void)unloadResourceDataWithID:(uint32_t)resourceID {
    dispatch_async(_resourceQueue, ^{
        [_resourceCacheQueue removeObject:@(resourceID)];
        NSData *data = _resourceCacheDict[@(resourceID)];
        _currentCacheSize -= data.length;
        [_resourceCacheDict removeObjectForKey:@(resourceID)];
    });
}


/**
 check if current memory's size, if large than the max size ,
 then release those less usage resources
 */
- (void)checkMemorySize {
    if (_currentCacheSize < _maxCacheSize) {
        return;
    }
    
    while (_currentCacheSize >= _maxCacheSize) {
        NSNumber *lastResourceID = [_resourceCacheQueue lastObject];
        [_resourceCacheQueue removeLastObject];
        NSData *lastData = _resourceCacheDict[lastResourceID];
        [_resourceCacheDict removeObjectForKey:lastResourceID];
        _currentCacheSize -= lastData.length;
        CEPrintf("LRU: release resource: %X\n", lastResourceID.unsignedIntValue);
    }
}


#pragma mark - load resource data from disk
- (NSData *)loadDataWithResourceID:(uint32_t)resourceID {
    CEResourceDataInfo *dataInfo = (CEResourceDataInfo *)[_dbContext queryById:@(resourceID) error:nil];
    if (!dataInfo) return nil;
    NSString *filePath = [_bundlePath stringByAppendingPathComponent:dataInfo.filePath];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [fileHandle seekToFileOffset:dataInfo.dataRange.location];
    //    NSData *fileData = [fileHandle readDataOfLength:dataInfo.dataRange.length];
    return [fileHandle readDataOfLength:dataInfo.dataRange.length];;
}


- (NSDictionary *)loadDataWithResourceIDs:(NSSet *)resourceIDs {
    if (!resourceIDs.count) {
        return nil;
    }
    NSMutableSet *resourceIDsToSearch = resourceIDs.mutableCopy;
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    while (resourceIDsToSearch.count) {
        NSNumber *searchID = [resourceIDsToSearch anyObject];
        CEResourceDataInfo *dataInfo = (CEResourceDataInfo *)[_dbContext queryById:searchID error:nil];
        if (!dataInfo) {
            [resourceIDsToSearch removeObject:searchID];
            continue;
        }
        NSString *filePath = [_bundlePath stringByAppendingPathComponent:dataInfo.filePath];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        [fileHandle seekToFileOffset:0];
        struct stat st;
        fstat([fileHandle fileDescriptor], &st);
        uint64_t bytesToRead = st.st_size;
        while (bytesToRead > 0) {
            NSData *headerData = [fileHandle readDataOfLength:8];
            int32_t length = 0;
            [headerData getBytes:&length length:4];
            if (!length || length > bytesToRead) {
                break;
            }
            uint32_t resourceID = 0;
            [headerData getBytes:&resourceID range:NSMakeRange(4, 4)];
            NSData *contentData = [fileHandle readDataOfLength:length - 8];
            if ([resourceIDsToSearch containsObject:@(resourceID)] && contentData.length) {
                dataDict[@(resourceID)] = contentData;
                [resourceIDsToSearch removeObject:@(resourceID)];
            }
            bytesToRead -= length;
        }
    }
    return dataDict.copy;
}


@end



