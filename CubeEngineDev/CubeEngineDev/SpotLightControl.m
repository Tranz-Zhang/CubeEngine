//
//  CESpotLightControl.m
//  CubeEngineDev
//
//  Created by tran2z on 4/28/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "SpotLightControl.h"


#define kAttenuationScale 50
#define kShiniessScale 30
#define kExponentScale 30

@interface SpotLightControl ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *attributeSegment;
@property (weak, nonatomic) IBOutlet UISlider *attributeSlider;

@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;

@end


@implementation SpotLightControl

#pragma mark - Attribute Value

- (IBAction)onAttributeSegmentChanged:(id)segment {
    switch (_attributeSegment.selectedSegmentIndex) {
        case 0:
            [_attributeSlider setValue:_operationLight.shiniess / kShiniessScale animated:YES];
            break;
        case 1:
//            [_attributeSlider setValue:_operationLight.specularItensity animated:YES];
            break;
        case 2:
            [_attributeSlider setValue:_operationLight.attenuation * kAttenuationScale animated:YES];
            break;
        case 3:
            [_attributeSlider setValue:_operationLight.coneAngle / 80 animated:YES];
            break;
        case 4:
            [_attributeSlider setValue:_operationLight.spotExponent / kExponentScale animated:YES];
            break;
            
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
            break;
        case 3:
            _operationLight.coneAngle = slider.value * 80;
            break;
        case 4:
            _operationLight.spotExponent = slider.value * kExponentScale;
            break;
            
        default:
            break;
    }
}

#pragma mark - Color Selection
- (IBAction)onColorSegmentChanged:(UISegmentedControl *)segment {
    switch (_colorSegment.selectedSegmentIndex) {
        case 0:
            [self updateColorSegmentWithColor:_operationLight.ambientColor];
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
            _operationLight.ambientColor = color;
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
