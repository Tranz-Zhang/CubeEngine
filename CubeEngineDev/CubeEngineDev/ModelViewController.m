//
//  ModelViewController.m
//  CubeEngineDev
//
//  Created by chance on 15/4/7.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "ModelViewController.h"
#import "CEObjFileLoader.h"

@implementation ModelViewController {
    CEModel *_testModel;
    __weak IBOutlet UILabel *_infoLabel;
    __weak IBOutlet UISwitch *_wireframeSwitch;
    __weak IBOutlet UISwitch *_accessorySwitch;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.camera.position = GLKVector3Make(20, 20, 20);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    self.scene.camera.nearZ = 10;
    self.scene.camera.farZ = 50;
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    _testModel = [CEModel modelWithObjFile:@"teapot_smooth"];
    _testModel.showWireframe = NO;
    _testModel.showAccessoryLine = YES;
    printf("Teapot loading duration: %.4f", CFAbsoluteTimeGetCurrent() - start);
    [self.scene addModel:_testModel];
    
    // add gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
    [self.view addGestureRecognizer:pinchGesture];
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotationGesture:)];
    [self.view addGestureRecognizer:rotationGesture];
    
    _wireframeSwitch.on = _testModel.showWireframe;
    _accessorySwitch.on = _testModel.showAccessoryLine;
}


- (IBAction)onWireframeSwitchChanged:(UISwitch *)switcher {
    _testModel.showWireframe = switcher.on;
}


- (IBAction)onAccessorySwitchChanged:(UISwitch *)switcher  {
    _testModel.showAccessoryLine = switcher.on;
}


- (IBAction)onReset:(id)sender {
    _testModel.eulerAngles = GLKVector3Make(0, 0, 0);
    _testModel.scale = GLKVector3Make(1, 1, 1);
}


#pragma mark - Gesture
static bool isHorizontalPan;
- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [panGesture translationInView:self.view];
        isHorizontalPan = ABS(translation.x) > ABS(translation.y);
        _infoLabel.hidden = NO;
        _infoLabel.textColor = isHorizontalPan ? [UIColor colorWithRed:60/255.0 green:175/255.0 blue:0 alpha:1] : [UIColor blueColor];
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self.view];
        [panGesture setTranslation:CGPointZero inView:self.view];
        GLKVector3 eulerAngles = _testModel.eulerAngles;
        if (isHorizontalPan) {
            eulerAngles.y += translation.x;
            _infoLabel.text = [NSString stringWithFormat:@"Rotation Yaw: %.2f°", eulerAngles.y];
            
        } else {
            eulerAngles.z -= translation.y;
            _infoLabel.text = [NSString stringWithFormat:@"Rotation Pitch: %.2f°", eulerAngles.z];
        }
        _testModel.eulerAngles = eulerAngles;
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded ||
               panGesture.state == UIGestureRecognizerStateCancelled) {
        _infoLabel.hidden = YES;
    }
}


- (void)onPinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        _infoLabel.hidden = NO;
        _infoLabel.textColor = [UIColor orangeColor];
        
    } else if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        _testModel.scale = GLKVector3MultiplyScalar(_testModel.scale, pinchGesture.scale);;
        _infoLabel.text = [NSString stringWithFormat:@"Scale: %.2f", _testModel.scale.x];
        pinchGesture.scale = 1;
        
    } else if (pinchGesture.state == UIGestureRecognizerStateEnded ||
               pinchGesture.state == UIGestureRecognizerStateCancelled) {
        _infoLabel.hidden = YES;
    }
}


- (void)onRotationGesture:(UIRotationGestureRecognizer *)rotationGesture {
    if (rotationGesture.state == UIGestureRecognizerStateBegan) {
        _infoLabel.hidden = NO;
        _infoLabel.textColor = [UIColor redColor];
        
    } else if (rotationGesture.state == UIGestureRecognizerStateChanged) {
        GLKVector3 eulerAngles = _testModel.eulerAngles;
        eulerAngles.x -= rotationGesture.rotation * 90;
        _testModel.eulerAngles = eulerAngles;
        rotationGesture.rotation = 0;
        _infoLabel.text = [NSString stringWithFormat:@"Rotation Roll: %.2f°", eulerAngles.x];
        
    } else if (rotationGesture.state == UIGestureRecognizerStateEnded ||
               rotationGesture.state == UIGestureRecognizerStateCancelled) {
        _infoLabel.hidden = YES;
    }
}


@end







