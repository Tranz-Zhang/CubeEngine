//
//  CEShaderLinkFunctionInfo.h
//  CubeEngine
//
//  Created by chance on 8/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"

@interface CEShaderLinkFunctionInfo : NSObject <CEJsonCoding>

@property (nonatomic, strong) NSString *functionID;
@property (nonatomic, strong) NSArray *paramNames;
@property (nonatomic, assign) NSRange linkRange;

@end
