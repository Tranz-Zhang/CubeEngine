//
//  CEShaderFunctionInfo.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShaderFunctionInfo : NSObject

@property (nonatomic, readonly, strong) NSString *functionID;
@property (nonatomic, readonly, strong) NSString *functionContent;
@property (nonatomic, readonly, strong) NSDictionary *linkFunctionDict; // {@"functionID" : @"rangeString"}

@end
