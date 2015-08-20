//
//  CEShaderFileParseResult.h
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShaderFileInfo : NSObject

@property (nonatomic, strong) NSSet *vertexShaderVariables;
@property (nonatomic, strong) NSString *vertexShaderContent;

@property (nonatomic, strong) NSSet *fragmentShaderVariables;
@property (nonatomic, strong) NSString *fragmentShaderContent;

@end
