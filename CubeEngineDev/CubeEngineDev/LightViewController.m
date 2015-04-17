//
//  LightViewController.m
//  CubeEngineDev
//
//  Created by chance on 4/17/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "LightViewController.h"
#import "CERenderer_Dev.h"


GLKVector3 Vec3WithColor(UIColor *color) {
    CGFloat r, g, b;
    [color getRed:&r green:&g blue:&b alpha:NULL];
    return GLKVector3Make(r, g, b);
}

GLKVector4 Vec4WithColor(UIColor *color) {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return GLKVector4Make(r, g, b, a);
}

UIColor * ColorWithVec3(GLKVector3 vec3) {
    return [UIColor colorWithRed:vec3.r green:vec3.g blue:vec3.b alpha:1];
}

UIColor * ColorWithVec4(GLKVector4 vec4) {
    return [UIColor colorWithRed:vec4.r green:vec4.g blue:vec4.b alpha:vec4.a];
}


@interface LightViewController ()<UIGestureRecognizerDelegate> {
    CEModel *_testModel;
}

@property (nonatomic, copy) UIColor *defaultColor;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *floatSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *singleValueSegment;

@property (weak, nonatomic) IBOutlet UISegmentedControl *attributeSegment;

@end

@implementation LightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.camera.position = GLKVector3Make(0, 30, 30);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    _testModel = [CEModel modelWithObjFile:@"teapot_smooth"];
    _testModel.showAccessoryLine = YES;
    [self.scene addModel:_testModel];
    
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
            [self setDefaultColor:ColorWithVec4([CERenderer_Dev shareRenderer].vertexColor)];
            break;
        case 1:
            [self setDefaultColor:ColorWithVec3([CERenderer_Dev shareRenderer].ambientColor)];
            break;
        case 2:
            [self setDefaultColor:ColorWithVec3([CERenderer_Dev shareRenderer].lightColor)];
            break;
        case 3:
            [self setDefaultColor:ColorWithVec3([CERenderer_Dev shareRenderer].lightDirection)];
            break;
        case 4:
            [self setDefaultColor:ColorWithVec3([CERenderer_Dev shareRenderer].halfVector)];
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
            [CERenderer_Dev shareRenderer].vertexColor = Vec4WithColor(color);
            break;
        case 1:
            [CERenderer_Dev shareRenderer].ambientColor = Vec3WithColor(color);
            break;
        case 2:
            [CERenderer_Dev shareRenderer].lightColor = Vec3WithColor(color);
            break;
        case 3:
            [CERenderer_Dev shareRenderer].lightDirection = Vec3WithColor(color);
            break;
        case 4:
            [CERenderer_Dev shareRenderer].halfVector = Vec3WithColor(color);
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
            [_floatSlider setValue:[CERenderer_Dev shareRenderer].shiniess / 30.0f animated:YES];
            break;
        case 1:
            [_floatSlider setValue:[CERenderer_Dev shareRenderer].strength animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)onFloatSliderChanged:(UISlider *)slider {
    switch (_singleValueSegment.selectedSegmentIndex) {
        case 0:
            [CERenderer_Dev shareRenderer].shiniess = MAX(1, slider.value * 30);
            break;
        case 1:
            [CERenderer_Dev shareRenderer].strength = slider.value;
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
    return touchPoint.y < _colorView.frame.origin.y;
}

@end









