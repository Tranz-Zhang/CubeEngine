//
//  CEObjFileLoader.h
//  CubeEngine
//
//  Created by chance on 15/4/2.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"

@interface CEObjFileLoader : NSObject

/**
 Parse the .obj file in the main bundle, return all models in it.
 @note If the file contain any mesh group structure, the top most model will be returned
 */
- (NSSet *)loadModelWithObjFileName:(NSString *)fileName;

@end
