//
//  LightViewController.m
//  CubeEngineDev
//
//  Created by chance on 4/17/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "DirectionalLightViewController.h"
#import "Common.h"
#import "CEDirectionalLight.h"
#import "CEPointLight.h"

@interface DirectionalLightViewController ()<UIGestureRecognizerDelegate> {
    CEObject *_operationObject;
    CEModel *_testModel;
    CEDirectionalLight *_diractionalLight;
    CEPointLight *_pointLight;
}

@property (nonatomic, copy) UIColor *defaultColor;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *floatSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *singleValueSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *attributeSegment;
@property (weak, nonatomic) IBOutlet UISwitch *lightOpereationSwitch;

@end

@implementation DirectionalLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.backgroundColor = [UIColor whiteColor];
    self.scene.camera.position = GLKVector3Make(0, 30, 30);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    _testModel = [CEModel modelWithObjFile:@"teapot_smooth"];
    _testModel.showAccessoryLine = YES;
    _testModel.baseColor = [UIColor orangeColor];
    [self.scene addModel:_testModel];
    _operationObject = _testModel;
    _lightOpereationSwitch.on = NO;
    
    _diractionalLight = [[CEDirectionalLight alloc] init];
    _diractionalLight.position = GLKVector3Make(8, 15, 0);
    _diractionalLight.scale = GLKVector3MultiplyScalar(_diractionalLight.scale, 5);
    [self.scene addLight:_diractionalLight];
    
    _pointLight = [CEPointLight new];
    _pointLight.scale = GLKVector3MultiplyScalar(_pointLight.scale, 5);
    _pointLight.position = GLKVector3Make(-8, 15, 0);
    _pointLight.specularItensity = 0.5;
    [self.scene addLight:_pointLight];
    
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
    _diractionalLight.eulerAngles = GLKVector3Make(0, 0, 0);
    _attributeSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _singleValueSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
}


- (IBAction)onLightOperationSwitch:(UISwitch *)sender {
    if (sender.on) {
        _operationObject = _diractionalLight;
        
    } else {
        _operationObject = _testModel;
    }
}


#pragma mark - Color Selection 
- (IBAction)onAttributeSegmentChanged:(UISegmentedControl *)segment {
    switch (_attributeSegment.selectedSegmentIndex) {
        case 0:
            [self setDefaultColor:_testModel.baseColor];
            break;
        case 1:
            [self setDefaultColor:_diractionalLight.ambientColor];
            break;
        case 2:
            [self setDefaultColor:_diractionalLight.lightColor];
            break;
            
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
        _colorView.backgroundColor = _defaultColor;
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
            _testModel.baseColor = color;
            break;
        case 1:
            _diractionalLight.ambientColor = color;
            break;
        case 2:
            _diractionalLight.lightColor = color;
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
            [_floatSlider setValue:_diractionalLight.shiniess / 30.0f animated:YES];
            break;
        case 1:
            [_floatSlider setValue:_diractionalLight.specularItensity animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)onFloatSliderChanged:(UISlider *)slider {
    switch (_singleValueSegment.selectedSegmentIndex) {
        case 0:
            _diractionalLight.shiniess = MAX(1, slider.value * 30);
            break;
        case 1:
            _diractionalLight.specularItensity = slider.value;
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
        GLKVector3 eulerAngles = _operationObject.eulerAngles;
        if (isHorizontalPan) {
            eulerAngles.y += translation.x;
            
        } else {
            eulerAngles.z -= translation.y;
        }
        _operationObject.eulerAngles = eulerAngles;
        NSLog(@"%@", [NSString stringWithFormat:@"Y: %.2f° Z: %.2f°", eulerAngles.y, eulerAngles.z]);
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded ||
               panGesture.state == UIGestureRecognizerStateCancelled) {

    }
}


- (void)onPinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        _operationObject.scale = GLKVector3MultiplyScalar(_operationObject.scale, pinchGesture.scale);;
        pinchGesture.scale = 1;
        
    } else if (pinchGesture.state == UIGestureRecognizerStateEnded ||
               pinchGesture.state == UIGestureRecognizerStateCancelled) {
        
    }
}


- (void)onRotationGesture:(UIRotationGestureRecognizer *)rotationGesture {
    if (rotationGesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (rotationGesture.state == UIGestureRecognizerStateChanged) {
        GLKVector3 eulerAngles = _operationObject.eulerAngles;
        eulerAngles.x -= rotationGesture.rotation * 90;
        _operationObject.eulerAngles = eulerAngles;
        rotationGesture.rotation = 0;
        
    } else if (rotationGesture.state == UIGestureRecognizerStateEnded ||
               rotationGesture.state == UIGestureRecognizerStateCancelled) {

    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    return touchPoint.y < _colorView.frame.origin.y;
}

@end









