//
//  CEModel.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"
#import "CEMesh.h"

@interface CEModel : CEObject {
    CEMesh *_mesh;
}

@property (nonatomic, readonly) CEMesh *mesh;

- (instancetype)initWithMesh:(CEMesh *)mesh;

@end
