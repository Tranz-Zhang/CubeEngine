//
//  CEObjFileLoader.h
//  CubeEngine
//
//  Created by chance on 15/4/2.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel_Deprecated.h"

@interface CEObjFileLoader : NSObject

+ (instancetype)shareLoader;

- (CEModel_Deprecated *)loadModelWithObjFilePath:(NSString *)filePath;

@end
