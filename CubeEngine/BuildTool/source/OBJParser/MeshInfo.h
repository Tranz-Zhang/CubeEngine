//
//  MeshInfo.h
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLInfo.h"

@interface MeshInfo : NSObject

@property (nonatomic, strong) NSArray *groupNames;
@property (nonatomic, readonly) uint32_t resourceID;
@property (nonatomic, strong) MTLInfo *materialInfo;
@property (nonatomic, assign) unsigned int maxIndex;
@property (nonatomic, strong) NSMutableArray *indicesList;
@property (nonatomic, assign) uint32_t indiceCount;
@property (nonatomic, assign) BOOL isOptimized;

- (GLenum)indicePrimaryType;
- (NSData *)buildIndiceData;
- (NSData *)buildOptimizedIndiceData;

@end
