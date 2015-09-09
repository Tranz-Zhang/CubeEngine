//
//  CEShaderStructInfo_setter.h
//  CubeEngine
//
//  Created by chance on 9/1/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderStructInfo.h"

@interface CEShaderStructInfo ()

@property (nonatomic, assign, readwrite) unsigned long long structID;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSArray *variables;

@end
