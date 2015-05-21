//
//  CEProgramLoader.m
//  CubeEngine
//
//  Created by chance on 5/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEProgramLoader.h"
#import "CEShaders.h"


@implementation CEProgramLoader

- (CEProgram *)loadProgramWithConfig:(CEProgramConfig *)config {
    NSMutableString *vertexShaderString = [kVertexShader mutableCopy];
    [vertexShaderString replaceOccurrencesOfString:@">>#" withString:@"#" options:0 range:NSMakeRange(0, vertexShaderString.length)];
    
    NSMutableString *fragmentShaderString = [kFragmentSahder mutableCopy];
    [fragmentShaderString replaceOccurrencesOfString:@">>#" withString:@"#" options:0 range:NSMakeRange(0, vertexShaderString.length)];
    
    if (config.lightCount > 0) {
        [vertexShaderString insertString:@"#define CE_ENABLE_LIGHTING\n" atIndex:0];
        [fragmentShaderString insertString:@"#define CE_ENABLE_LIGHTING\n" atIndex:0];
        [fragmentShaderString replaceOccurrencesOfString:@"CE_LIGHT_COUNT"
                                              withString:[NSString stringWithFormat:@"%d", config.lightCount]
                                                 options:0
                                                   range:NSMakeRange(0, fragmentShaderString.length)];
    }
    if (config.enableShadowMapping) {
        [vertexShaderString insertString:@"#define CE_ENABLE_SHADOW_MAPPING\n" atIndex:0];
        [fragmentShaderString insertString:@"#define CE_ENABLE_SHADOW_MAPPING\n" atIndex:0];
    }
    
    return nil;
}

@end



