//
//  PointLightViewController.m
//  CubeEngineDev
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "PointLightViewController.h"
#import "CERenderer_PointLight.h"
#import "Common.h"

@interface PointLightViewController ()<UIGestureRecognizerDelegate> {
    CEModel *_testModel;
}

@property (nonatomic, copy) UIColor *defaultColor;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *floatSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *singleValueSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *attributeSegment;

@end

@implementation PointLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.camera.position = GLKVector3Make(0, 30, 30);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    _testModel = [CEModel modelWithObjFile:@"teapot_smooth"];
    _testModel.showAccessoryLine = YES;
    [self.scene addModel:_testModel];
    
    [CERenderer_PointLight shareRenderer].lightLocation = GLKVector3Make(20, 20, 20);
    
    // add gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotationGesture:)];
    rotationGesture.delegate = self;
    [self.view addGestureRecognizer:rotationGesture];
}


- (IBAction)onReset:(id)sender {
    _testModel.eulerAngles = GLKVector3Make(0, 0, 0);
    _testModel.scale = GLKVector3Make(1, 1, 1);
    _attributeSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _singleValueSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
}


#pragma mark - Color Selection
- (IBAction)onAttributeSegmentChanged:(UISegmentedControl *)segment {
    switch (_attributeSegment.selectedSegmentIndex) {
        case 0:
            [self setDefaultColor:ColorWithVec4([CERenderer_PointLight shareRenderer].vertexColor)];
            break;
        case 1:
            [self setDefaultColor:ColorWithVec3([CERenderer_PointLight shareRenderer].ambientColor)];
            break;
        case 2:
            [self setDefaultColor:ColorWithVec3([CERenderer_PointLight shareRenderer].lightColor)];
            break;
        case 3: {
            GLKVector3 position = [CERenderer_PointLight shareRenderer].lightLocation;
            [self setDefaultColor:ColorWithVec3(GLKVector3Make(position.x / 25, position.y / 25, position.z / 25))];
            break;
        }
            
        case UISegmentedControlNoSegment:
        default:
            break;
    }
}


- (void)setDefaultColor:(UIColor *)defaultColor {
    if (defaultColor != _defaultColor) {
        _defaultColor = [defaultColor copy];
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        [_defaultColor getRed:&red green:&green blue:&blue alpha:NULL];
        [_redSlider setValue:red animated:YES];
        [_greenSlider setValue:green animated:YES];
        [_blueSlider setValue:blue animated:YES];
    }
}

- (IBAction)onRedSliderChanged:(id)sender {
    [self updateDefaultColor];
}

- (IBAction)onBlueSliderChanged:(id)sender {
    [self updateDefaultColor];
}

- (IBAction)onGreenSliderChanged:(id)sender {
    [self updateDefaultColor];
}

- (void)updateDefaultColor {
    UIColor *color = [UIColor colorWithRed:_redSlider.value green:_greenSlider.value blue:_blueSlider.value alpha:1];
    self.defaultColor = color;
    
    switch (_attributeSegment.selectedSegmentIndex) {
        case 0:
            [CERenderer_PointLight shareRenderer].vertexColor = Vec4WithColor(color);
            break;
        case 1:
            [CERenderer_PointLight shareRenderer].ambientColor = Vec3WithColor(color);
            break;
        case 2:
            [CERenderer_PointLight shareRenderer].lightColor = Vec3WithColor(color);
            break;
        case 3:
            [CERenderer_PointLight shareRenderer].lightLocation = GLKVector3Make(_redSlider.value * 50 - 25,
                                                                                 _greenSlider.value * 50 - 25,
                                                                                 _blueSlider.value * 50 - 25);
            break;
        case UISegmentedControlNoSegment:
        default:
            break;
    }
}


#pragma mark - Single Value

- (IBAction)onSingleValueSegmentChanged:(id)segment {
    switch (_singleValueSegment.selectedSegmentIndex) {
        case 0:
            [_floatSlider setValue:[CERenderer_PointLight shareRenderer].shiniess / 30.0f animated:YES];
            break;
        case 1:
            [_floatSlider setValue:[CERenderer_PointLight shareRenderer].strength animated:YES];
            break;
        case 2:
            [_floatSlider setValue:[CERenderer_PointLight shareRenderer].constantAttenuation * 10000 animated:YES];
            break;
        case 3:
            [_floatSlider setValue:[CERenderer_PointLight shareRenderer].linearAttenuation animated:YES];
            break;
        case 4:
            [_floatSlider setValue:[CERenderer_PointLight shareRenderer].quadraticAttenuation animated:YES];
            break;
            
        default:
            break;
    }
}

- (IBAction)onFloatSliderChanged:(UISlider *)slider {
    switch (_singleValueSegment.selectedSegmentIndex) {
        case 0:
            [CERenderer_PointLight shareRenderer].shiniess = MAX(1, slider.value * 30);
            break;
        case 1:
            [CERenderer_PointLight shareRenderer].strength = slider.value;
            break;
        case 2:
            [CERenderer_PointLight shareRenderer].constantAttenuation = slider.value / 10000;
            break;
        case 3:
            [CERenderer_PointLight shareRenderer].linearAttenuation = slider.value;
            break;
        case 4:
            [CERenderer_PointLight shareRenderer].quadraticAttenuation = slider.value;
            break;
            
        default:
            break;
    }
}

#pragma mark - Gesture
static bool isHorizontalPan;
- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [panGesture translationInView:self.view];
        isHorizontalPan = ABS(translation.x) > ABS(translation.y);
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self.view];
        [panGesture setTranslation:CGPointZero inView:self.view];
        GLKVector3 eulerAngles = _testModel.eulerAngles;
        if (isHorizontalPan) {
            eulerAngles.y += translation.x;
            
        } else {
            eulerAngles.z -= translation.y;
        }
        _testModel.eulerAngles = eulerAngles;
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded ||
               panGesture.state == UIGestureRecognizerStateCancelled) {
        
    }
}


- (void)onPinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        _testModel.scale = GLKVector3MultiplyScalar(_testModel.scale, pinchGesture.scale);;
        pinchGesture.scale = 1;
        
    } else if (pinchGesture.state == UIGestureRecognizerStateEnded ||
               pinchGesture.state == UIGestureRecognizerStateCancelled) {
        
    }
}


- (void)onRotationGesture:(UIRotationGestureRecognizer *)rotationGesture {
    if (rotationGesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (rotationGesture.state == UIGestureRecognizerStateChanged) {
        GLKVector3 eulerAngles = _testModel.eulerAngles;
        eulerAngles.x -= rotationGesture.rotation * 90;
        _testModel.eulerAngles = eulerAngles;
        rotationGesture.rotation = 0;
        
    } else if (rotationGesture.state == UIGestureRecognizerStateEnded ||
               rotationGesture.state == UIGestureRecognizerStateCancelled) {
        
    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    return touchPoint.y < _singleValueSegment.frame.origin.y;
}


@end


