//
//  CEShaderFunctionInfo.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShaderFunctionInfo : NSObject

@property (nonatomic, strong) NSString *functionID;
@property (nonatomic, strong) NSString *functionContent;
@property (nonatomic, strong) NSDictionary *linkFunctionDict; // {@"functionID" : @"rangeString"}

@end
