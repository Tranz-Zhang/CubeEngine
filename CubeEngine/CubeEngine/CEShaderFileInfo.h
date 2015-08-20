//
//  CEShaderFileParseResult.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShaderFileInfo : NSObject

@property (nonatomic, readonly, strong) NSSet *vertexShaderVariables;
@property (nonatomic, readonly, strong) NSString *vertexShaderContent;

@property (nonatomic, readonly, strong) NSSet *fragmentShaderVariables;
@property (nonatomic, readonly, strong) NSString *fragmentShaderContent;

@end
