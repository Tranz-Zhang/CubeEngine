//
//  CEViewController.m
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEViewController.h"
#import "CEModel.h"
#import "CERenderer.h"

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


GLfloat gTriangleVertexData[108] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    
    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    1.5f, -0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
    1.5f, -0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    
    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    1.5f, -0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
    0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
    
    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    1.5f, -0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    // bottom
    0.5f, -0.5f, -0.5f,    0.0f, -1.0f, 0.0f,
    1.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
    1.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    1.5f, -0.5f, 0.5f,      0.0f, -1.0f, 0.0f,
};

@implementation CEViewController {
    CEModel *_testObject;
    CEScene *_scene;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _scene = [CEScene new];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _scene = [CEScene new];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _scene.camera.aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    NSData *vertexData = [NSData dataWithBytes:gTriangleVertexData length:sizeof(gTriangleVertexData)];
    _testObject = [[CEModel alloc] initWithVertexData:vertexData dataType:CEVertextDataType_V3];
    _testObject.location = GLKVector3Make(0, 0, 0);
//    _testObject.transformMatrix = GLKMatrix4Identity;
    
    [_scene addRenderObject:_testObject];
    
    GLKView *view = (GLKView *)self.view;
    view.context = _scene.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    
    //
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    GLKMatrix4 testMatrix = GLKMatrix4MakeLookAt(2, 2, 2, 0, 0, 0, 0, 1, 0);
    GLKQuaternion quarternion = GLKQuaternionMakeWithMatrix4(testMatrix);
//    GLKVector3 axis = GLKQuaternionAxis(quarternion);
//    float radian = GLKQuaternionAngle(quarternion);
//    GLKMatrix4 returnMatrix = GLKMatrix4MakeWithQuaternion(quarternion);
//    returnMatrix = GLKMatrix(returnMatrix, radian, axis);
    printf("CalculationDuration: %.8f", CFAbsoluteTimeGetCurrent() - startTime);
}

static float rotation = 0;
- (void)update {
    rotation += self.timeSinceLastUpdate * 50;
//    [_testObject setRotation:rotation onPivot:CERotationPivotX|CERotationPivotY|CERotationPivotZ];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_scene update];
}





@end
