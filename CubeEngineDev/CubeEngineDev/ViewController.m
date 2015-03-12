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
}
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectionSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *objectSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cameraSegment;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"Cube Engine Dev: %@", CUBE_ENGINE_VERSION];
    _objectSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _cameraSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _selectionSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _isLookingAtObject = NO;
    [self updateInfoView];
}

- (IBAction)onReset:(id)sender {
    self.testObject.location = GLKVector3Make(0, 0, 0);
    [self.testObject setRotation:0 onPivot:CERotationPivotNone];
    self.testObject.scale = 1;
    self.scene.camera.location = GLKVector3Make(0, 0, 4);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    _objectSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _cameraSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _selectionSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    _valueSlider.value = 0;
    
    [self updateInfoView];
}


- (IBAction)onCameraSettingChanged:(id)sender {
    _objectSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    [_valueSlider setValue:0.5 animated:YES];
}

- (IBAction)onObjectSettingChanged:(id)sender {
    _cameraSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    [_valueSlider setValue:0.5 animated:YES];
}

- (void)updateInfoView {
    NSMutableString *infoString = [NSMutableString string];
    [infoString appendFormat:@"Object (%.2f, %.2f, %.2f)\n", self.testObject.location.x, self.testObject.location.y, self.testObject.location.z];
    [infoString appendFormat:@"Camera (%.2f, %.2f, %.2f)", self.scene.camera.location.x, self.scene.camera.location.y, self.scene.camera.location.z];
    self.infoTextView.text = infoString;
}


- (IBAction)onSliderValueChange:(UISlider *)slider {
    if (_objectSegment.selectedSegmentIndex != UISegmentedControlNoSegment) {
        switch (_objectSegment.selectedSegmentIndex) {
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
        
    } else if (_cameraSegment.selectedSegmentIndex != UISegmentedControlNoSegment) {
        switch (_cameraSegment.selectedSegmentIndex) {
            case 0:
                [self testCameraNearZWithSlider:slider];
                break;
                
            case 1:
                [self testCameraFarZWithSlider:slider];
                break;
                
            case 2:
                [self testCameraPositionWithSlider:slider];
                break;
                
            default:
                break;
        }
    }
    if (_isLookingAtObject) {
        [self.scene.camera lookAt:self.testObject.location];
    }
    [self updateInfoView];
}

#pragma mark - Test Object Transfrom

- (void)testObjectLocationWithSlider:(UISlider *)slider {
    GLKVector3 location = self.testObject.location;
    switch (_selectionSegment.selectedSegmentIndex) {
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
    self.testObject.location = location;
}

- (void)testObjectRotationWithSlider:(UISlider *)slider {
    switch (_selectionSegment.selectedSegmentIndex) {
        case 0:
            [self.testObject setRotation:slider.value * 360 - 180
                                 onPivot:CERotationPivotX];
            break;
            
        case 1:
            [self.testObject setRotation:slider.value * 360 - 180
                                 onPivot:CERotationPivotY];
            break;
            
        case 2:
            [self.testObject setRotation:slider.value * 360 - 180
                                 onPivot:CERotationPivotZ];
            break;
            
        default:
            break;
    }
}

- (void)testObjectScaleWithSlider:(UISlider *)slider {
    self.testObject.scale = slider.value * 2 - 1;
}

#pragma mark - Test Camera Transfrom

- (IBAction)onLookAt:(UIButton *)button {
    _isLookingAtObject = !_isLookingAtObject;
    button.selected = _isLookingAtObject;
    if (_isLookingAtObject) {
       [self.scene.camera lookAt:self.testObject.location];
    }
}

- (void)testCameraNearZWithSlider:(UISlider *)slider {
    self.scene.camera.nearZ = slider.value * 10 + 0.1;
}


- (void)testCameraFarZWithSlider:(UISlider *)slider {
    self.scene.camera.farZ = slider.value * 10;
}

- (void)testCameraPositionWithSlider:(UISlider *)slider {
    GLKVector3 location = self.scene.camera.location;
    switch (_selectionSegment.selectedSegmentIndex) {
        case 0:
            location.x = slider.value * 10 - 5;
            break;
            
        case 1:
            location.y = slider.value * 10 - 5;
            break;
            
        case 2:
            location.z = slider.value * 10 - 5;
            break;
            
        default:
            break;
    }
    self.scene.camera.location = location;
}


@end
