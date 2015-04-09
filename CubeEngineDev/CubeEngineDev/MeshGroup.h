//
//  MeshGroup.h
//  CubeEngineDev
//
//  Created by chance on 15/4/8.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VertexElementType) {
    VertexElementType_Unknown = 0,
    VertexElementType_V,
    VertexElementType_V_VT,
    VertexElementType_V_VT_VN,
    VertexElementType_V_VN,
};

@interface MeshGroup : NSObject

@property (nonatomic, strong) NSArray *groupNames;
@property (nonatomic, assign) VertexElementType elementType;
@property (nonatomic, strong) NSMutableData *meshData;

@end
