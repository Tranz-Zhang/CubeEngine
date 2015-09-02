//
//  CEShaderFunctionInfo_setter.h
//  CubeEngine
//
//  Created by chance on 9/1/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderFunctionInfo.h"

@interface CEShaderFunctionInfo ()

@property (nonatomic, strong, readwrite) NSString *functionID;
@property (nonatomic, strong, readwrite) NSString *functionContent;
@property (nonatomic, strong, readwrite) NSArray *paramNames;
@property (nonatomic, strong, readwrite) NSArray *paramLocations;
@property (nonatomic, strong, readwrite) NSDictionary *linkFunctionDict;

@end
