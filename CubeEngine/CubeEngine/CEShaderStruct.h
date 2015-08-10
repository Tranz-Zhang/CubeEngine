//
//  CEShaderStruct.h
//  CubeEngine
//
//  Created by chance on 8/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShaderVariableDefines.h"

@interface CEShaderStruct : NSObject {
    NSString *_name;
}

+ (instancetype)structWithName:(NSString *)name;

@end
