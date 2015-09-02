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

@property (nonatomic, readonly) NSString *functionID;
@property (nonatomic, readonly) NSString *functionContent;
@property (nonatomic, readonly) NSArray *paramNames;      // name of function param in order
@property (nonatomic, readonly) NSArray *paramLocations;  // NSArray of NSArray to store params location in functionContent
@property (nonatomic, readonly) NSDictionary *linkFunctionDict; // {@"functionID" : CEShaderLinkFunctionInfo}

@end
