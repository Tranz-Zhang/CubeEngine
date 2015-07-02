//
//  PointLightControl.m
//  CubeEngineDev
//
//  Created by tran2z on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "PointLightControl.h"

#define kAttenuationScale 50

@interface PointLightControl ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *attributeSegment;
@property (weak, nonatomic) IBOutlet UISlider *attributeSlider;

@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;

@end


@implementation PointLightControl

#pragma mark - Attribute Value

- (IBAction)onAttributeSegmentChanged:(id)segment {
    switch (_attributeSegment.selectedSegmentIndex) {
        case 0:
            [_attributeSlider setValue:_operationLight.shiniess / 30.0f animated:YES];
            break;
        case 1:
//            [_attributeSlider setValue:_operationLight.specularItensity animated:YES];
            break;
        case 2:
            [_attributeSlider setValue:_operationLight.attenuation * kAttenuationScale animated:YES];
        default:
            break;
    }
}

- (IBAction)onAttributeSliderChanged:(UISlider *)slider {
    switch (_attributeSegment.selectedSegmentIndex) {
        case 0:
            _operationLight.shiniess = MAX(1, slider.value * 30);
            break;
        case 1:
//            _operationLight.specularItensity = slider.value;
            break;
        case 2:
            _operationLight.attenuation = slider.value / kAttenuationScale;
        default:
            break;
    }
}

#pragma mark - Color Selection
- (IBAction)onColorSegmentChanged:(UISegmentedControl *)segment {
    switch (_colorSegment.selectedSegmentIndex) {
        case 0:
//            [self updateColorSegmentWithColor:_operationLight.ambientColor];
            break;
        case 1:
            [self updateColorSegmentWithColor:_operationLight.lightColor];
            break;
            
        case UISegmentedControlNoSegment:
        default:
            break;
    }
}

- (void)updateColorSegmentWithColor:(UIColor *)color {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    _redSlider.value = red;
    _greenSlider.value = green;
    _blueSlider.value = blue;
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
    switch (_colorSegment.selectedSegmentIndex) {
        case 0:
//            _operationLight.ambientColor = color;
            break;
        case 1:
            _operationLight.lightColor = color;
            break;
        case UISegmentedControlNoSegment:
        default:
            break;
    }
}





@end
