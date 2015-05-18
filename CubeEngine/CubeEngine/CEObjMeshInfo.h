//
//  CEObjMeshGroup.h
//  CubeEngine
//
//  Created by chance on 5/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEObjMeshInfo : NSObject

@property (nonatomic, strong) NSArray *groupNames;
@property (nonatomic, strong) NSString *materialName;
@property (nonatomic, strong) NSMutableData *meshData;
@property (nonatomic, strong) NSArray *attributes;

@end
