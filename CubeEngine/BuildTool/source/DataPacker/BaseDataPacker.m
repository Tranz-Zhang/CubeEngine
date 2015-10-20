//
//  BaseDataPacker.m
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BaseDataPacker.h"
#import "BaseDataPacker_private.h"
#import "CEDB.h"
#import "CEResourceDataInfo.h"


@implementation BaseDataPacker {
    CEDatabase *_db;
    CEDatabaseContext *_dbContext;
    NSString *_appPath;
}


- (instancetype)initWithAppPath:(NSString *)appPath {
    self = [super init];
    if (self) {
        _appPath = [appPath copy];
        NSString *configDir = [appPath stringByAppendingPathComponent:kConfigDirectory];
        if ([[NSFileManager defaultManager] fileExistsAtPath:configDir]) {
            _db = [CEDatabase databaseWithName:kResourceDataDBName inPath:configDir];
            _dbContext = [CEDatabaseContext contextWithTableName:kDBTableResourceData
                                                           class:[CEResourceDataInfo class]
                                                      inDatabase:_db];
            if (!ENABLE_INCREMENTAL_UPDATE) {
                [_dbContext removeAllObjectsWithError:nil];
            }
        }
    }
    return self;
}


- (NSString *)writeData:(NSDictionary *)dataDict {
    if (!_db || !_dbContext || !dataDict.count || ![self targetFileDirectory]) {
        return NO;
    }
    
    NSMutableArray *insertDataInfos = [NSMutableArray array];
    NSMutableArray *updateDataInfos = [NSMutableArray array];
    NSMutableData *resourceData = [NSMutableData data];
    uint32_t mainResourceID = [dataDict.allKeys[0] unsignedIntValue];
    NSString *relativeFilePath = [NSString stringWithFormat:@"%@/%08X", [self targetFileDirectory], mainResourceID];
    NSString *filePath = [_appPath stringByAppendingPathComponent:relativeFilePath];
    [dataDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *resourceID, NSData *data, BOOL *stop) {
        uint32_t uResourceID = [resourceID unsignedIntValue];
        if (resourceID && data.length) {
            uint32_t dataBlockLength = (uint32_t)data.length + 2 * sizeof(uint32_t);
            [resourceData appendBytes:&dataBlockLength length:sizeof(uint32_t)];
            [resourceData appendBytes:&uResourceID length:sizeof(uint32_t)];
            [resourceData appendData:data];
            
            CEResourceDataInfo *info = (CEResourceDataInfo *)[_dbContext queryById:@(uResourceID) error:nil];
            if (info) {
                [updateDataInfos addObject:info];
                
            } else {
                info = [CEResourceDataInfo new];
                [insertDataInfos addObject:info];
            }
            info.resourceID = uResourceID;
            info.dataRange = NSMakeRange(resourceData.length - data.length, data.length);
            info.filePath = relativeFilePath;
        }
    }];
    if (!resourceData.length || (!insertDataInfos.count && !updateDataInfos.count)) {
        return nil;
    }
    // write DB
    NSError *error;
    if (![_dbContext updateObjects:updateDataInfos error:&error]) {
        NSLog(@"Fail to update resource data info to db: %@\n", [error localizedDescription]);
        return nil;
    }
    if (![_dbContext insertObjects:insertDataInfos error:&error]) {
        NSLog(@"Fail to insert resource data info to db: %@\n", [error localizedDescription]);
        return nil;
    }
    
    // write resource file
    if (![resourceData writeToFile:filePath atomically:YES]) {
        printf("Fail to write resource data\n");
        return nil;
    }
    return filePath;
}



- (NSString *)targetFileDirectory {
    return nil;
}



@end

