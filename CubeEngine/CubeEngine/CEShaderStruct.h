//
//  CEShaderStruct.h
//  CubeEngine
//
//  Created by chance on 8/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEShaderStruct : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray *variables;

+ (instancetype)structWithName:(NSString *)name variables:(NSArray *)variables;

@end
