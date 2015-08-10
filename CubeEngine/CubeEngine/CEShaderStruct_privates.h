//
//  CEShaderStruct_private.h
//  CubeEngine
//
//  Created by chance on 8/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderStruct.h"

@interface CEShaderStruct ()

/* name of the stuct declared in shader, MUST IMPLEMENTED BY SUBCLASS*/
- (NSString *)structName;

/* declaration string in shader for current struct, MUST IMPLEMENTED BY SUBCLASS */
- (NSString *)declarationString;


@end
