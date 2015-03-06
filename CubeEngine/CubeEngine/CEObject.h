//
//  CEObject.h
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEObject : NSObject

// geometry properties
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKMatrix4 transformMatrix;
@property (nonatomic, strong) NSData *vertexData;

@end
