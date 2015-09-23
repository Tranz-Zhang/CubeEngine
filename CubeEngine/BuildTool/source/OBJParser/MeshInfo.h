//
//  MeshInfo.h
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeshInfo : NSObject

@property (nonatomic, strong) NSArray *groupNames;
@property (nonatomic, strong) NSString *materialName;
@property (nonatomic, strong) NSMutableData *meshData;
@property (nonatomic, strong) NSMutableData *indicesData;
@property (nonatomic, strong) NSArray *attributes;

@end
