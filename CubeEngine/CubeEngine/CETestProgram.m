//
//  CETestProgram.m
//  CubeEngine
//
//  Created by chance on 15/3/10.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CETestProgram.h"

NSString *const kTestVertexShader = CE_SHADER_STRING
(
 attribute highp vec4 position;
 uniform mat4 projection;
 
 void main () {
     gl_Position = projection * position;
 }
 );

NSString *const kTestFragmentSahder = CE_SHADER_STRING
(
 uniform lowp vec4 drawColor;
 void main() {
     gl_FragColor = drawColor;
 }
 );


@implementation CETestProgram

+ (instancetype)defaultProgram {
    CETestProgram *program = [[CETestProgram alloc] initWithVertexShaderString:kTestVertexShader
                                                          fragmentShaderString:kTestFragmentSahder];
    return program;
}

- (BOOL)link {
    if (self.initialized) {
        return YES;
    }
    [self addAttribute:@"position"];
    BOOL isOK = [super link];
    if (isOK) {
        _attributePosotion = [self attributeIndex:@"position"];
        _uniformProjection = [self uniformIndex:@"projection"];
        _uniformDrawColor = [self uniformIndex:@"drawColor"];
        
    } else {
        // print error info
        NSString *progLog = [self programLog];
        CEError(@"Program link log: %@", progLog);
        NSString *fragLog = [self fragmentShaderLog];
        CEError(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [self vertexShaderLog];
        CEError(@"Vertex shader compile log: %@", vertLog);
    }
    
    return isOK;
}


@end



