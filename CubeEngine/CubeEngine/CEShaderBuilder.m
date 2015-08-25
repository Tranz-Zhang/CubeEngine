//
//  CEShaderBuilder.m
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderBuilder.h"
#import "CEShaderProfile.h"
#import "CEUtils.h"


@implementation CEShaderBuilder {
    NSMutableArray *_uniforms;
    NSMutableArray *_attritubes;
    NSMutableArray *_varyings;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (CEShaderBuildResult *)build {
    CEShaderProfile *mainProfile = [self shaderProfileWithName:@"Main"];
    
    return nil;
}


- (void)buildShaderProgram:(NSArray *)shaderProfiles {
    
}


- (CEShaderProfile *)shaderProfileWithName:(NSString *)shaderName {
    if (!shaderName) return nil;
    
    static NSMutableDictionary *sShaderProfileCache;
    if (!sShaderProfileCache) {
        sShaderProfileCache = [NSMutableDictionary dictionary];
    }
    
    CEShaderProfile *profile = sShaderProfileCache[shaderName];
    if (profile) return profile;
    
    // load from disk
    NSData *jsonData = [NSData dataWithContentsOfFile:[CEShaderDirectory() stringByAppendingFormat:@"/%@.ceshader", shaderName]];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    profile = [[CEShaderProfile alloc] initWithJsonDict:jsonDict];
    sShaderProfileCache[shaderName] = profile;
    return profile;
}




@end

