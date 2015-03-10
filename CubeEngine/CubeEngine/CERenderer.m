//
//  CERenderer.m
//  CubeEngine
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CETestProgram.h"
#import "CEObject_Rendering.h"

@implementation CERenderer {
    CETestProgram *_program;
    
    // clear color
    CGFloat _clearColorRed;
    CGFloat _clearColorGreen;
    CGFloat _clearColorBlue;
    CGFloat _clearColorAlpha;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupOpenGL];
    }
    return self;
}


- (void)setupOpenGL {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            GEPrintf("Fail to init context");
            return;
        }
    }
    
    [EAGLContext setCurrentContext:_context];
    
    _program = [CETestProgram defaultProgram];
    if (![_program link]) {
        _program = nil;
        CELog(@"Fail to setup program");
        
    } else {
        CELog(@"Setup program OK");
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        [_backgroundColor getRed:&_clearColorRed
                           green:&_clearColorGreen
                            blue:&_clearColorBlue
                           alpha:&_clearColorAlpha];
    }
}


- (void)renderObject:(CEModel *)object {
    if (!object || !_program) {
        CELog(@"Can not render object");
        return;
    }
    
    glClearColor(_clearColorRed, _clearColorGreen, _clearColorBlue, _clearColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [EAGLContext setCurrentContext:_context];
    
    glBindBuffer(GL_ARRAY_BUFFER, object.vertexBufferIndex);
    glEnableVertexAttribArray(_program.attributePosotion);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, 0);
    [_program use];
    
    // TODO:render object with different programs
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_cameraProjectionMatrix, [self tranformMatrixForObject:object]);
    glUniformMatrix4fv(_program.uniformProjection, 1, 0, projectionMatrix.m);
    glUniform4f(_program.uniformDrawColor, 0.6, 0.6, 0.6, 1.0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glUniform4f(_program.uniformDrawColor, 1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_LINE_STRIP, 0, 36);
}


- (GLKMatrix4)tranformMatrixForObject:(CEModel *)object {
    GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(object.location.x,
                                                          object.location.y,
                                                          object.location.z);
    if (object.rotationPivot) {
        tranformMatrix = GLKMatrix4Rotate(tranformMatrix,
                                          GLKMathDegreesToRadians(object.rotationDegree),
                                          object.rotationPivot & CERotationPivotX ? 1 : 0,
                                          object.rotationPivot & CERotationPivotY ? 1 : 0,
                                          object.rotationPivot & CERotationPivotZ ? 1 : 0);
    }
    if (object.scale != 1) {
        tranformMatrix = GLKMatrix4Scale(tranformMatrix, object.scale, object.scale, object.scale);
    }
    return tranformMatrix;
}


@end
