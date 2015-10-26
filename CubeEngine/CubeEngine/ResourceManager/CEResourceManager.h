//
//  CEResourceManager.h
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CEResourceDataProcessProtocol <NSObject>

- (NSDictionary *)processDataDict:(NSDictionary *)dictionary;

@end


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
 Asynchronously loading resource data into main memory, 
 will call process delegate after loading data dict,
 can use to process data before cached by resource manager.
 */
- (void)loadResourceDataWithIDs:(NSArray *)resourceIDs
                processDelegate:(id <CEResourceDataProcessProtocol>)processDelegate
                     completion:(CEResourceDataLoadedCompletion)completion;

/**
 release data from main memory
 */
- (void)unloadResourceDataWithID:(uint32_t)resourceID;



#pragma mark - Runtime Resource ID 

+ (uint32_t)generateRuntmeResourceID;
+ (void)recycleRuntimeResourceID:(uint32_t)resourceID;

@end


