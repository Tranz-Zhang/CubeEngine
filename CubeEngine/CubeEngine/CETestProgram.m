//
//  CETestProgram.m
//  CubeEngine
//
//  Created by chance on 15/3/10.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CETestProgram.h"

NSString *const kTestVertexShader = SHADER_STRING
(
 attribute highp vec4 position;
 uniform mat4 projection;
 
 void main () {
     gl_Position = projection * position;
 }
 );

NSString *const kTestFragmentSahder = SHADER_STRING
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
        CELog(@"Program link log: %@", progLog);
        NSString *fragLog = [self fragmentShaderLog];
        CELog(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [self vertexShaderLog];
        CELog(@"Vertex shader compile log: %@", vertLog);
    }
    
    return isOK;
}


@end



