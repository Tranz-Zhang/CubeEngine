//
//  ViewController.m
//  CubeEngineDev
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ViewController.h"
#import "CubeEngine.h"



@interface ViewController () {
    BOOL _isLookingAtObject;
    BOOL _isAttachingObject;
}
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *objectSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *operationSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *coordinateSegment;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"Cube Engine Dev: %@", CUBE_ENGINE_VERSION];
    _isLookingAtObject = NO;
    [self updateInfoView];
}

- (IBAction)onReset:(id)sender {
    self.testObject.position = GLKVector3Make(0, 0, 0);
    self.testObject.scale = GLKVector3Make(1, 1, 1);
    self.testObject.rotation = GLKQuaternionIdentity;
    self.testObject2.position = GLKVector3Make(0, 0, 0);
    self.testObject2.scale = GLKVector3Make(1, 1, 1);
    self.testObject2.rotation = GLKQuaternionIdentity;
    self.scene.camera.location = GLKVector3Make(0, 5, 5);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    _objectSegment.selectedSegmentIndex = 0;
    _operationSegment.selectedSegmentIndex = 0;
    _coordinateSegment.selectedSegmentIndex = 0;
    _valueSlider.value = 0.5;
    
    [self updateInfoView];
}

- (void)updateInfoView {
    NSMutableString *infoString = [NSMutableString string];
    [infoString appendFormat:@"Object (%.2f, %.2f, %.2f)\n", self.testObject.position.x, self.testObject.position.y, self.testObject.position.z];
    [infoString appendFormat:@"Camera (%.2f, %.2f, %.2f)", self.scene.camera.location.x, self.scene.camera.location.y, self.scene.camera.location.z];
    self.infoTextView.text = infoString;
}

- (IBAction)onLookAt:(UIButton *)button {
    CEObject *currentObject = [self currentObject];
    [currentObject lookAt:self.testObject2.position];
}

- (IBAction)onAttach:(UIButton *)button {
    _isAttachingObject = !_isAttachingObject;
    button.selected = _isAttachingObject;
    
    if (_isAttachingObject) {
        [self.testObject2 addChildObject:self.testObject];
        
    } else {
        [self.testObject removeFromParent];
    }
}

#pragma mark - Transform

- (IBAction)onSliderValueChange:(UISlider *)slider {
    switch (_operationSegment.selectedSegmentIndex) {
        case 0:
            [self testObjectLocationWithSlider:slider];
            break;
            
        case 1:
            [self testObjectRotationWithSlider:slider];
            break;
            
        case 2:
            [self testObjectScaleWithSlider:slider];
            break;
            
        default:
            break;
    }
    
    if (_isLookingAtObject) {
        [self.scene.camera lookAt:self.testObject.position];
    }
}

#pragma mark - Test Object Transfrom

- (CEObject *)currentObject {
    switch (_objectSegment.selectedSegmentIndex) {
        case 0:
            return self.testObject;
            
        case 1:
            return self.testObject2;
            
        case 2:
            return nil;
            
        default:
            return nil;
    }
}

- (void)testObjectLocationWithSlider:(UISlider *)slider {
    CEObject *currentObject = [self currentObject];
    GLKVector3 location = currentObject.position;
    switch (_coordinateSegment.selectedSegmentIndex) {
        case 0:
            location.x = slider.value * 6 - 3;
            break;
            
        case 1:
            location.y = slider.value* 6 - 3;
            break;
            
        case 2:
            location.z = slider.value* 6 - 3;
            break;
            
        default:
            break;
    }
    currentObject.position = location;
}

- (void)testObjectRotationWithSlider:(UISlider *)slider {
    CEObject *currentObject = [self currentObject];
    GLKVector3 rotationAngles = currentObject.eulerAngles;
    switch (_coordinateSegment.selectedSegmentIndex) {
        case 0:
            rotationAngles.x = slider.value * 360 - 180;
            break;
            
        case 1:
            rotationAngles.y = slider.value * 360 - 180;
            break;
            
        case 2:
            rotationAngles.z = slider.value * 360 - 180;
            break;
            
        default:
            break;
    }
    
    currentObject.eulerAngles = rotationAngles;
}

- (void)testObjectScaleWithSlider:(UISlider *)slider {
    CEObject *currentObject = [self currentObject];
    GLKVector3 scale = currentObject.scale;
    switch (_coordinateSegment.selectedSegmentIndex) {
        case 0:
            scale.x = slider.value * 2;
            break;
            
        case 1:
            scale.y = slider.value * 2;
            break;
            
        case 2:
            scale.z = slider.value * 2;
            break;
            
        default:
            break;
    }
    
    currentObject.scale = scale;
}

- (IBAction)onSliderStop:(id)sender {
    [self updateInfoView];
}






@end
