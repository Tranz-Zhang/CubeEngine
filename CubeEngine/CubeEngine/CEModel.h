//
//  CEModel.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"
#import "CEMaterial.h"

@interface CEModel : CEObject

@property (nonatomic, strong) NSString *name;

// the bounds in 3D space
@property (nonatomic, readonly) GLKVector3 bounds;

// the model's center's offset from original point in Model Space.
@property (nonatomic, readonly) GLKVector3 offsetFromOrigin;

// default is white
@property (nonatomic, copy) UIColor *baseColor;

// indicates if cast shadows under light, default is NO;
@property (nonatomic, assign) BOOL castShadows;

// materials info of the model
@property (nonatomic, strong) CEMaterial *material;


+ (CEModel *)modelWithObjFile:(NSString *)objFileName;

// recursive search child model with the indicated name
- (CEModel *)childWithName:(NSString *)modelName;

- (CEModel *)duplicate DEPRECATED_ATTRIBUTE;


#pragma mark - debug

// indicates if show wireframe under debug mode
@property (nonatomic, assign) BOOL showWireframe;

// indicates if show bounds and coordinate line under debug mode;
@property (nonatomic, assign) BOOL showAccessoryLine;


@end

