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

// indicates if cast shadows under light, default is NO;
@property (nonatomic, assign) BOOL enableShadow;

// recursive search child model with the indicated name
- (CEModel *)childWithName:(NSString *)modelName;


#pragma mark - debug

// indicates if show wireframe under debug mode
@property (nonatomic, assign) BOOL showWireframe;

// indicates if show bounds and coordinate line under debug mode;
@property (nonatomic, assign) BOOL showAccessoryLine;


@end

