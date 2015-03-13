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
    _scene.camera.location = GLKVector3Make(0, 5, 5);
    [_scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    NSData *vertexData = [NSData dataWithBytes:gTriangleVertexData length:sizeof(gTriangleVertexData)];
    _testObject = [CEModel modelWithVertexData:vertexData type:CEVertextDataType_V3N3];
//    _testObject.transformMatrix = GLKMatrix4Identity;

    [_scene addRenderObject:_testObject];
    
    NSInteger size = sizeof(gCubeVertexData);
    NSData *vertexData2 = [NSData dataWithBytes:gCubeVertexData length:sizeof(gCubeVertexData)];
    CEModel *testObject2 = [CEModel modelWithVertexData:vertexData2 type:CEVertextDataType_V3N3];
    [_scene addRenderObject:testObject2];
    
    GLKView *view = (GLKView *)self.view;
    view.context = _scene.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    
//    GLKQuaternion qX = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(60), 1, 0, 0);
//    GLKQuaternion qy = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(60), 0, 1, 0);
//    GLKQuaternion combine = GLKQuaternionMultiply(qX, qy);
//    float angle = GLKQuaternionAngle(combine);
//    GLKVector3 axis = GLKQuaternionAxis(combine);
//    
//    GLKVector3 direction = GLKVector3Make(0, 0, 1);
//    GLKMatrix3 rotationMatrix = GLKMatrix3MakeXRotation(GLKMathDegreesToRadians(60));
//    rotationMatrix = GLKMatrix3RotateWithVector3(<#GLKMatrix3 matrix#>, <#float radians#>, <#GLKVector3 axisVector#>)
//    
////    rotationMatrix = GLKMatrix3MakeXRotation(GLKMathDegreesToRadians(60));
//    
//    float angleX = atan2(rotationMatrix.m12, rotationMatrix.m22);
//    angleX = GLKMathRadiansToDegrees(angleX);
//    
//    float angleY = atan2(-rotationMatrix.m02, sqrt(pow(rotationMatrix.m12, 2) + pow(rotationMatrix.m22, 2)));
//    angleY = GLKMathRadiansToDegrees(angleY);
}



#pragma mark - rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat aspect1 = self.view.bounds.size.width / self.view.bounds.size.height;
    CGFloat aspect2 = self.view.bounds.size.height / self.view.bounds.size.width;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _scene.camera.aspect = MIN(aspect1, aspect2);
        
    } else {
        _scene.camera.aspect = MAX(aspect1, aspect2);
    }
}

// for iOS 8
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _scene.camera.aspect = size.width / size.height;
}


#pragma mark - rendering

static float rotation = 0;
- (void)update {
    rotation += self.timeSinceLastUpdate * 50;
//    [_testObject setRotation:rotation onPivot:CERotationPivotX|CERotationPivotY|CERotationPivotZ];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_scene update];
}





@end
