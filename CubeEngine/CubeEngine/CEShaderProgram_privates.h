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
 Get output Attributes or Uniforms in current program. return nil if no item match the name and type;
 */
- (CEShaderVariable *)outputVariableWithName:(NSString *)name type:(NSString *)typeString;


@end

