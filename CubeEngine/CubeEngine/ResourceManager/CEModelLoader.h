//
//  CEModelLoader.h
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"

typedef void(^CEModelLoadingCompletion)(CEModel *model);

@interface CEModelLoader : NSObject

+ (instancetype)defaultLoader;

/** Asynchronously load a model's resouces with the specify name */
- (void)loadModelWithName:(NSString *)name completion:(CEModelLoadingCompletion)completion;

/** Fetch all model names in db */
- (NSArray *)allModelNames;

@end
