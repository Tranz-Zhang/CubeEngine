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

- (void)loadModelWithName:(NSString *)name completion:(CEModelLoadingCompletion)completion;

@end
