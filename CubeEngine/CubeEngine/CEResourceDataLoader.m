//
//  CEResourceDataLoader.m
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <sys/stat.h>
#import "CEResourceDataLoader.h"
#import "CEResourceDefines.h"
#import "CEDB.h"
#import "CEResourceDataInfo.h"


@implementation CEResourceDataLoader {
    NSString *_bundlePath;
    CEDatabase *_db;
    CEDatabaseContext *_dbContext;
}


+ (instancetype)defaultLoader {
    static CEResourceDataLoader *_shareInstance;
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
        _bundlePath = [[NSBundle mainBundle] bundlePath];
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


- (NSData *)loadDataWithResourceID:(uint32_t)resourceID {
    CEResourceDataInfo *dataInfo = (CEResourceDataInfo *)[_dbContext queryById:@(resourceID) error:nil];
    if (!dataInfo) return nil;
    NSString *filePath = [_bundlePath stringByAppendingPathComponent:dataInfo.filePath];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [fileHandle seekToFileOffset:dataInfo.dataRange.location];
//    NSData *fileData = [fileHandle readDataOfLength:dataInfo.dataRange.length];
    return [fileHandle readDataOfLength:dataInfo.dataRange.length];;
}


- (NSDictionary *)loadDataWithResourceIDs:(NSArray *)resourceIDs {
    if (!resourceIDs.count) {
        return nil;
    }
    NSMutableSet *resourceIDsToSearch = [NSMutableSet setWithArray:resourceIDs];
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

