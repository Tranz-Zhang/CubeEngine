//
//  CEShaderLinkFunctionInfo_setter.h
//  CubeEngine
//
//  Created by chance on 9/1/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderLinkFunctionInfo.h"

@interface CEShaderLinkFunctionInfo ()

@property (nonatomic, strong, readwrite) NSString *functionID;
@property (nonatomic, strong, readwrite) NSArray *paramNames;
@property (nonatomic, assign, readwrite) NSRange linkRange;

@end
