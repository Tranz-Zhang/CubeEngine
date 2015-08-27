//
//  CEShaderFunctionInfo.h
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEJsonCoding.h"
#import "CEShaderLinkFunctionInfo.h"

@interface CEShaderFunctionInfo : NSObject <CEJsonCoding>

@property (nonatomic, strong) NSString *functionID;
@property (nonatomic, strong) NSString *functionContent;
@property (nonatomic, strong) NSArray *paramNames;      // name of function param in order
@property (nonatomic, strong) NSArray *paramLocations;  // NSArray of NSArray to store params location in functionContent
@property (nonatomic, strong) NSDictionary *linkFunctionDict; // {@"functionID" : CEShaderLinkFunctionInfo}

@end
