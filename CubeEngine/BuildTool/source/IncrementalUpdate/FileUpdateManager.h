//
//  FileUpdateManager.h
//  CubeEngine
//
//  Created by chance on 10/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUpdateInfo.h"

@interface FileUpdateManager : NSObject

+ (instancetype)sharedManager;

/** check if file at path is modified since last time
 @param filePath source file path
 @param autoDelete delete last result file if source file is out of date.
 @return boolean value indicates that if source file is out of date
 */
- (BOOL)isFileUpToDateAtPath:(NSString *)filePath autoDelete:(BOOL)autoDelete;

/**
 update a record for the manager
 */
- (void)updateInfoWithSourcePath:(NSString *)sourceFilePath
                      resultPath:(NSString *)resultFilePath;

// clean up useless result files
- (void)cleanUp;

@end
