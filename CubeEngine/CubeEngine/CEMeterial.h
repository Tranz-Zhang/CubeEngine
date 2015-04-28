//
//  CEMeterial.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEMeterial : NSObject

@property (nonatomic, assign) GLKVector3 emission;  // light produced by the meterial
@property (nonatomic, assign) GLKVector3 ambient;   //
@property (nonatomic, assign) GLKVector3 diffuse;
@property (nonatomic, assign) GLKVector3 specular;
@property (nonatomic, assign) float shiniess;


@end
