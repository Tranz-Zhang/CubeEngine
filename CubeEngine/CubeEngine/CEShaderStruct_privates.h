//
//  CEShaderStruct_private.h
//  CubeEngine
//
//  Created by chance on 8/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderStruct.h"

@interface CEShaderStruct ()

/* struct instance declaration in shader, implement by super class */
- (NSString *)declaration;


/* struct name in shader, MUST IMPLEMENTED BY SUBCLASS*/
+ (NSString *)structName;


/* struct declaration in shader, MUST IMPLEMENTED BY SUBCLASS */
+ (NSString *)structDeclaration;


@end
