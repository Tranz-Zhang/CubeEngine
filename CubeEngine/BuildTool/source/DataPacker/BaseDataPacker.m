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
            [_dbContext removeAllObjectsWithError:nil];
        }
    }
    return self;
}


- (NSString *)writeData:(NSDictionary *)dataDict {
    if (!_db || !_dbContext || !dataDict.count || ![self targetFileDirectory]) {
        return NO;
    }
    
    NSMutableArray *dataInfos = [NSMutableArray arrayWithCapacity:dataDict.count];
    NSMutableData *resourceData = [NSMutableData data];
    uint32_t mainResourceID = [dataDict.allKeys[0] unsignedIntValue];
    NSString *relativeFilePath = [NSString stringWithFormat:@"%@/%X", [self targetFileDirectory], mainResourceID];
    NSString *filePath = [_appPath stringByAppendingPathComponent:relativeFilePath];
    [dataDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *resourceID, NSData *data, BOOL *stop) {
        uint32_t uResourceID = [resourceID unsignedIntValue];
        if (resourceID && data.length) {
            uint32_t dataBlockLength = (uint32_t)data.length + 2 * sizeof(uint32_t);
            [resourceData appendBytes:&dataBlockLength length:sizeof(uint32_t)];
            [resourceData appendBytes:&uResourceID length:sizeof(uint32_t)];
            [resourceData appendData:data];
            
            CEResourceDataInfo *info = [CEResourceDataInfo new];
            info.resourceID = uResourceID;
            info.dataRange = NSMakeRange(resourceData.length - data.length, data.length);
            info.filePath = relativeFilePath;
            [dataInfos addObject:info];
        }
    }];
    if (!resourceData.length || !dataInfos.count) {
        return nil;
    }
    // write DB
    NSError *error;
    if (![_dbContext insertObjects:dataInfos error:&error]) {
        printf("Fail to insert resource data info to db: %s\n", [[error localizedDescription] UTF8String]);
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

