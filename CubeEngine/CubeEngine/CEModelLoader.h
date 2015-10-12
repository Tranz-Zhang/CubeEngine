//
//  CEModelLoader.h
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"

@interface CEModelLoader : NSObject

- (void)loadModelWithName:(NSString *)name completion:(void(^)(CEModel *model))completion;

@end
