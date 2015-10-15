//
//  FileUpdateInfo.h
//  CubeEngine
//
//  Created by chance on 10/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface FileUpdateInfo : CEManagedObject

BIND_OBJECT_ID(fileID);
@property (nonatomic, assign) NSUInteger fileID;
@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, strong) NSString *resultPath;

@end
