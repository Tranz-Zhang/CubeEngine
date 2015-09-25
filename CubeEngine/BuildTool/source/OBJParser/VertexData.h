//
//  VertexData.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VertexData : NSObject

@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector2 uv;
@property (nonatomic, assign) GLKVector3 normal;
@property (nonatomic, assign) GLKVector3 tangent;

@end
