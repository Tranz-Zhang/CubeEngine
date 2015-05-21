//
//  CEProgramLoader.h
//  CubeEngine
//
//  Created by chance on 5/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEProgram.h"
#import "CEProgramConfig.h"

@interface CEProgramLoader : NSObject

- (CEProgram *)loadProgramWithConfig:(CEProgramConfig *)config;

@end
