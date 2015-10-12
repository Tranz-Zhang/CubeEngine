//
//  CEResourceDataLoader.h
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 CEResourceDataLoader loads data from disk by resource id.
 */
@interface CEResourceDataLoader : NSObject

+ (instancetype)defaultLoader;

/** read data from disk with the specify resource id */
- (NSData *)loadDataWithResourceID:(uint32_t)resourceID;

/**
 bench read data from disk with resource id list
 
 @param resourceIDs list of resource id, @[@(resourceID), @(resourceID), ...]
 @return data dictionary, @{@(resourceID) : NSData, ...}
 */
- (NSDictionary *)loadDataWithResourceIDs:(NSArray *)resourceIDs;

@end
