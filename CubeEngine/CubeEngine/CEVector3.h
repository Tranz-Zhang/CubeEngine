//
//  CEVector3.h
//  CubeEngine
//
//  Created by chance on 15/3/13.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEVector3 : NSObject

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) float z;

+ (CEVector3 *)vectorWithGLKVector:(GLKVector3)vector3;

- (BOOL)isEqual:(id)object;

@end

