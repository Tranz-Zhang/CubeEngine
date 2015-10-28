//
//  CEModel_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "CEModel.h"
#import "CERenderObject.h"

@interface CEModel ()

- (instancetype)initWithName:(NSString *)name renderObjects:(NSArray *)renderObjects;

@property (nonatomic, readwrite) GLKVector3 bounds;
@property (nonatomic, readwrite) GLKVector3 offsetFromOrigin;
@property (nonatomic, readonly) NSArray *renderObjects;

@end
