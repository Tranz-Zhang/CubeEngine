//
//  OBJFileInfo.h
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeshInfo.h"
#import "VertexData.h"
#import "VectorList.h"

@interface OBJFileInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mtlFileName;
@property (nonatomic, strong) NSArray *meshInfos; // array of MeshInfo
//@property (nonatomic, strong) NSData *vertexData;

@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) VectorList *vertexDataList;

@property (nonatomic, strong) VectorList *positionList;
@property (nonatomic, strong) VectorList *uvList;
@property (nonatomic, strong) VectorList *normalList;
@property (nonatomic, strong) VectorList *tangentList;

@end