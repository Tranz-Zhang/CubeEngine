//
//  CEShaderBuilder.m
//  CubeEngine
//
//  Created by chance on 8/16/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEProgramBuilder.h"
#import "CEShaderRoutine.h"
#import "CEShaderRoutineBaseLight.h"

@interface CEShaderVariableInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *attribute;  // attribute/uniform/required

@end

@implementation CEProgramBuilder {
    BOOL _enableLight;
    BOOL _enableTexture;
    BOOL _enableNormalMap;
    BOOL _enableShadowMap;
}


- (void)startBuildingNewProgram {
    _enableLight = NO;
    _enableTexture = NO;
    _enableNormalMap = NO;
    _enableShadowMap = NO;
}

- (void)enableLight:(BOOL)enabled {
    _enableLight = enabled;
}

- (void)enableTexture:(BOOL)enabled {
    _enableTexture = enabled;
}

- (void)enableNormalMap:(BOOL)enabled {
    _enableNormalMap = enabled;
}

- (void)enableShadowMap:(BOOL)enabled {
    _enableShadowMap = enabled;
}

- (CEShaderProgram *)buildProgram {
    
    NSMutableArray *routines = [NSMutableArray array];
    if (_enableTexture) {
        //add texture routine;
    }
    if (_enableLight) {
        CEShaderRoutine *lightRoutine;
        if (_enableNormalMap) {
            // add normal map lighting
            
        } else {
            lightRoutine = [CEShaderRoutineBaseLight new];
        }
        if (_enableShadowMap) {
            // add shadow map routine
        }
    }
    
    // render mode
    
    
    return nil;
}

- (NSString *)vertexShaderWithRoutines:(NSArray *)routines {
    NSMutableString *declarationString = [NSMutableString string];
    NSMutableString *mainString = [NSMutableString string];
    
    return nil;
}


- (NSString *)fragmentShaderWithRoutines:(NSArray *)routines {
    return nil;
}



@end


