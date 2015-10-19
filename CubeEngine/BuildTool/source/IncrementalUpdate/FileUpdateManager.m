//
//  FileUpdateManager.m
//  CubeEngine
//
//  Created by chance on 10/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "FileUpdateManager.h"
#import "CEDB.h"

@implementation FileUpdateManager {
    CEDatabase *_db;
    CEDatabaseContext *_dbContext;
    NSMutableSet *_unusedFileIDs;
}

+ (instancetype)sharedManager {
    static FileUpdateManager *_shareInstance;
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
        if (ENABLE_INCREMENTAL_UPDATE) {
            _db = [CEDatabase databaseWithName:@"file_update_info" inPath:[kAppPath stringByDeletingLastPathComponent]];
            _dbContext = [CEDatabaseContext contextWithTableName:@"file_info" class:[FileUpdateInfo class] inDatabase:_db];
            
            // get all file ids
            _unusedFileIDs = [NSMutableSet set];
            NSArray *allInfos = [_dbContext queryAllWithError:nil];
            for (FileUpdateInfo *info in allInfos) {
                [_unusedFileIDs addObject:@(info.fileID)];
            }
            
        } else {
            NSString *dbPath = [[kAppPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"file_update_info"];
            [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
        }
    }
    return self;
}


- (BOOL)isFileUpToDateAtPath:(NSString *)filePath autoDelete:(BOOL)autoDelete {
    if (!ENABLE_INCREMENTAL_UPDATE) {
        return NO;
    }
    
    // get local file info
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if (![fileAttributes fileModificationDate]) {
        return NO;
    }
    
    // get file update info
    FileUpdateInfo *updateInfo = (FileUpdateInfo *)[_dbContext queryById:@([filePath hash]) error:nil];
    if (!updateInfo) return NO;
    [_unusedFileIDs removeObject:@(updateInfo.fileID)];
    
    // check result file
    if (![[NSFileManager defaultManager] fileExistsAtPath:updateInfo.resultPath]) {
        return NO;
    }
    
    // compare date
    NSDate *lastModifiedDate = [fileAttributes fileModificationDate];
    BOOL isUpToDate = ([lastModifiedDate timeIntervalSince1970] == updateInfo.lastUpdateTime);
    if (!isUpToDate && autoDelete) {
        // delete last result file
        [[NSFileManager defaultManager] removeItemAtPath:updateInfo.resultPath error:nil];
    }
    return isUpToDate;
}


- (void)updateInfoWithSourcePath:(NSString *)sourceFilePath resultPath:(NSString *)resultFilePath {
    if (!ENABLE_INCREMENTAL_UPDATE) {
        return;
    }
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:sourceFilePath error:nil];
    if (![fileAttributes fileModificationDate]) {
        return;
    }
    NSDate *lastModifiedDate = [fileAttributes fileModificationDate];
    NSUInteger fileID = [sourceFilePath hash];
    FileUpdateInfo *updateInfo = (FileUpdateInfo *)[_dbContext queryById:@(fileID) error:nil];
    if (updateInfo) {
        updateInfo.lastUpdateTime = [lastModifiedDate timeIntervalSince1970];
        updateInfo.resultPath = resultFilePath;
        [_dbContext update:updateInfo error:nil];
        
    } else {
        updateInfo = [FileUpdateInfo new];
        updateInfo.fileID = fileID;
        updateInfo.sourcePath = sourceFilePath;
        updateInfo.lastUpdateTime = [lastModifiedDate timeIntervalSince1970];
        updateInfo.resultPath = resultFilePath;
        [_dbContext insert:updateInfo error:nil];
    }
}


- (void)cleanUp {
    if (!ENABLE_INCREMENTAL_UPDATE) {
        return;
    }
    
    NSLog(@"Clean up: %s\n", _unusedFileIDs.count ? "" : "none");
    for (NSNumber *fileID in _unusedFileIDs) {
        FileUpdateInfo *info = (FileUpdateInfo *)[_dbContext queryById:fileID error:nil];
        if (info && [[NSFileManager defaultManager] removeItemAtPath:info.resultPath error:nil]) {
            [_dbContext remove:info error:nil];
            NSLog(@" - remove: %s\n", info.resultPath.UTF8String);
        }
    }
}



@end


