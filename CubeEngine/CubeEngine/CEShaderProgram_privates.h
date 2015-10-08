//
//  CEShaderProgram_privates.h
//  CubeEngine
//
//  Created by chance on 9/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProgram.h"

@interface CEShaderProgram ()

/**
 Get uniform variable in current program. return nil if no item match the name and type;
 */
- (CEShaderVariable *)uniformVariableWithName:(NSString *)name type:(NSString *)dataType;


@end

