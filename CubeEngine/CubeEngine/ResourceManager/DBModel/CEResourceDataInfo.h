//
//  CEResourceInfo.h
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CEResourceDataInfo : CEManagedObject

BIND_OBJECT_ID(resourceID);
@property (nonatomic, assign) uint32_t resourceID;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSRange dataRange;

@end
