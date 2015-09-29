//
//  CETextureInfo.h
//  CubeEngine
//
//  Created by chance on 9/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEManagedObject.h"

@interface CETextureInfo : CEManagedObject

@property (nonatomic, assign) int32_t textureID;
@property (nonatomic, strong) NSString *textureDataPath;
@property (nonatomic, assign) NSValue *textureSize;

@end
