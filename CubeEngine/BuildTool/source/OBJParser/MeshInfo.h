//
//  MeshInfo.h
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaterialInfo.h"

@interface MeshInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *groupNames;
@property (nonatomic, readonly) uint32_t resourceID;
@property (nonatomic, strong) MaterialInfo *materialInfo;
@property (nonatomic, assign) unsigned int maxIndex;
@property (nonatomic, strong) NSMutableArray *indicesList;
@property (nonatomic, assign) uint32_t indiceCount;
//@property (nonatomic, assign) BOOL isOptimized;

@property (nonatomic, assign) GLenum indicePrimaryType;
@property (nonatomic, assign) GLenum drawMode;


- (NSData *)buildIndiceData;
- (NSData *)buildOptimizedIndiceData;

@end
