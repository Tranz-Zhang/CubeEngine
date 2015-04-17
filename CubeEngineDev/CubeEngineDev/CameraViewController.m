//
//  CameraViewController.m
//  CubeEngineDev
//
//  Created by chance on 4/16/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.camera.position = GLKVector3Make(0, 30, 30);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    CEModel *testModel = [CEModel modelWithObjFile:@"teapot"];
    testModel.showAccessoryLine = YES;
    [self.scene addModel:testModel];
    
    // add gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotationGesture:)];
    [self.view addGestureRecognizer:rotationGesture];
    
    [self updateCameraPositionInfo];
}


- (IBAction)onReset:(id)sender {
    self.scene.camera.position = GLKVector3Make(0, 30, 30);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    [self updateCameraPositionInfo];
}

- (IBAction)onLookAt:(id)sender {
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
}

#pragma mark - position

- (IBAction)onFoward:(id)sender {
    GLKVector3 position = self.scene.camera.position;
    position.z += 1;
    self.scene.camera.position = position;
    [self updateCameraPositionInfo];
}

- (IBAction)onBackward:(id)sender {
    GLKVector3 position = self.scene.camera.position;
    position.z -= 1;
    self.scene.camera.position = position;
    [self updateCameraPositionInfo];
}

- (IBAction)onLeft:(id)sender {
    GLKVector3 position = self.scene.camera.position;
    position.x -= 1;
    self.scene.camera.position = position;
    [self updateCameraPositionInfo];
}

- (IBAction)onRight:(id)sender {
    GLKVector3 position = self.scene.camera.position;
    position.x += 1;
    self.scene.camera.position = position;
    [self updateCameraPositionInfo];
}

- (IBAction)onUp:(id)sender {
    GLKVector3 position = self.scene.camera.position;
    position.y += 1;
    self.scene.camera.position = position;
    [self updateCameraPositionInfo];
}

- (IBAction)onDown:(id)sender {
    GLKVector3 position = self.scene.camera.position;
    position.y -= 1;
    self.scene.camera.position = position;
    [self updateCameraPositionInfo];
}

- (void)updateCameraPositionInfo {
    GLKVector3 position = self.scene.camera.position;
    _infoLabel.text = [NSString stringWithFormat:@"Camera Position:( %.0f, %.0f, %.0f )", position.x, position.y, position.z];
}


#pragma mark - Rotation
static bool isHorizontalPan;
- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [panGesture translationInView:self.view];
        isHorizontalPan = ABS(translation.x) > ABS(translation.y);
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self.view];
        [panGesture setTranslation:CGPointZero inView:self.view];
        GLKVector3 eulerAngles = self.scene.camera.eulerAngles;
        eulerAngles.y -= translation.x / 5.0f;
        eulerAngles.x -= translation.y / 5.0f;
        self.scene.camera.eulerAngles = eulerAngles;
        _infoLabel.text = [NSString stringWithFormat:@"Y: %.2f° X: %.2f°", eulerAngles.y, eulerAngles.x];
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded ||
               panGesture.state == UIGestureRecognizerStateCancelled) {
        [self updateCameraPositionInfo];
    }
}

- (void)onRotationGesture:(UIRotationGestureRecognizer *)rotationGesture {
    if (rotationGesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (rotationGesture.state == UIGestureRecognizerStateChanged) {
        GLKVector3 eulerAngles = self.scene.camera.eulerAngles;
        eulerAngles.z -= rotationGesture.rotation * 90;
        self.scene.camera.eulerAngles = eulerAngles;
        rotationGesture.rotation = 0;
        _infoLabel.text = [NSString stringWithFormat:@"Z: %.2f°", eulerAngles.z];
        
    } else if (rotationGesture.state == UIGestureRecognizerStateEnded ||
               rotationGesture.state == UIGestureRecognizerStateCancelled) {
        [self updateCameraPositionInfo];
    }
}

@end



