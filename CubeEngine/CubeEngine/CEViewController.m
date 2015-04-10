//
//  CEViewController.m
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEViewController.h"

@implementation CEViewController {
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
    GLKView *view = (GLKView *)self.view;
    view.context = _scene.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
/*
 GLKMatrix4 rotationMatrix = GLKMatrix4Identity;
//    rotationMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(GLKMathDegreesToRadians(45), 1, 0, 0), rotationMatrix);
//    rotationMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(GLKMathDegreesToRadians(45), 0, 1, 0), rotationMatrix);
//    rotationMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(GLKMathDegreesToRadians(45), 0, 0, 1), rotationMatrix);
    
    GLKQuaternion rotationQuaternion = GLKQuaternionIdentity;
    rotationQuaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(88), 1, 0, 0), rotationQuaternion);
    rotationQuaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(15), 0, 1, 0), rotationQuaternion);
    rotationQuaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(23), 0, 0, 1), rotationQuaternion);
    
    rotationMatrix = GLKMatrix4MakeWithQuaternion(rotationQuaternion);
    float angleX = atan2(rotationMatrix.m12, rotationMatrix.m22);
    float angleY = atan2(-rotationMatrix.m02, sqrt(pow(rotationMatrix.m12, 2) + pow(rotationMatrix.m22, 2)));
    float angleZ = atan2(rotationMatrix.m10, rotationMatrix.m00);
    
    angleX = GLKMathRadiansToDegrees(angleX);
    angleY = GLKMathRadiansToDegrees(angleY);
    angleZ = GLKMathRadiansToDegrees(angleZ);
    printf("(%.1f, %.1f, %.1f)\n", angleX, angleY, angleZ);
    
    GLKQuaternion quaternion = rotationQuaternion;
    angleX = atan2(2 * (quaternion.w * quaternion.x + quaternion.z * quaternion.y),
                   1 - 2 * (pow(quaternion.x, 2) + pow(quaternion.y, 2)));
    angleY = asin(2 * (quaternion.w * quaternion.y - quaternion.x * quaternion.z));
    angleZ = atan2(2 * (quaternion.w * quaternion.z + quaternion.x * quaternion.y),
                   1- 2 * (pow(quaternion.y, 2) + pow(quaternion.z, 2)));
    
    angleX = GLKMathRadiansToDegrees(angleX);
    angleY = GLKMathRadiansToDegrees(angleY);
    angleZ = GLKMathRadiansToDegrees(angleZ);
    printf("(%.1f, %.1f, %.1f)\n", angleX, angleY, angleZ);
    
    
    printf("onTestRotation\n\n");
    CEObject *testObject = [CEObject new];
    testObject.eulerAngles = GLKVector3Make(30, 40, 50);
    testObject.eulerAngles = GLKVector3Make(12.4, 56.7, 89.6);
    testObject.eulerAngles = GLKVector3Make(-30, 40, 50);
    testObject.eulerAngles = GLKVector3Make(30, -40, -50);
    testObject.eulerAngles = GLKVector3Make(230, 190, 260);
    testObject.eulerAngles = GLKVector3Make(25, 90, 45);
    testObject.eulerAngles = GLKVector3Make(-135, 135, 135);
    testObject.eulerAngles = GLKVector3Make(-135, -197, 270);
    testObject.eulerAngles = GLKVector3Make(20, -180, -160);
//*/
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
