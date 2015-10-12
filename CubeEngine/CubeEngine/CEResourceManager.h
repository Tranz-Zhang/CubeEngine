//
//  CEResourceManager.h
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 resourceDataDict -> @{@(resourceID) : NSData}
 */
typedef void (^CEResourceDataLoadedCompletion)(NSDictionary *resourceDataDict);

@interface CEResourceManager : NSObject

+ (instancetype)sharedManager;

/**
 Asynchronously loading resource data into main memory
 */
- (void)loadResourceDataWithIDs:(NSArray *)resourceIDs
                     completion:(CEResourceDataLoadedCompletion)completion;

/**
 release data from main memory
 */
- (void)unloadResourceDataWithID:(uint32_t)resourceID;

#warning TEST LRU

@end
