//
//  ModelViewController.m
//  CubeEngineDev
//
//  Created by chance on 15/4/7.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "ModelViewController.h"
#import "CEObjFileLoader.h"
#import "ObjectOperator.h"
#import "CEDirectionalLight.h"


@implementation ModelViewController {
    CEModel *_testModel;
    CELight *_light;
    ObjectOperator *_operator;
    __weak IBOutlet UISwitch *_wireframeSwitch;
    __weak IBOutlet UISwitch *_accessorySwitch;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.camera.position = GLKVector3Make(0, 20, 20);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];

//    self.scene.camera.position = GLKVector3Make(0, 2, 5);
//    [self.scene.camera lookAt:GLKVector3Make(0, 1, 0)];
//    self.scene.camera.nearZ = 0;
//    self.scene.camera.farZ = 100;
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    _testModel = [CEModel modelWithObjFile:@"test_scene"];
    _testModel.scale = GLKVector3Make(1.2, 1.2, 1.2);
//    _testModel.showWireframe = YES;
    _testModel.showAccessoryLine = YES;
//    _testModel.material.specularColor = GLKVector3Make(1, 1, 1);
//    _testModel.material.shiniess = 20;
//    _testModel.material.diffuseTexture = nil;// @"gray_texture.png";
//    _testModel.material.normalTexture = nil;
    [self recursiveSetColorForModel:_testModel];
    for (CEModel *model in _testModel.childObjects) {
        if ([model.name isEqualToString:@"leaf"]) {
            model.material.materialType = CEMaterialAlphaTested;
        }
    }
    
    printf("model loading duration: %.4f\n", CFAbsoluteTimeGetCurrent() - start);
    [self.scene addModel:_testModel];
    
    _wireframeSwitch.on = _testModel.showWireframe;
    _accessorySwitch.on = _testModel.showAccessoryLine;
    
    _operator = [[ObjectOperator alloc] initWithBaseView:self.view];
    _operator.operationObject = _testModel;
    
    CEDirectionalLight *directionalLight = [[CEDirectionalLight alloc] init];
    directionalLight.position = GLKVector3Make(4, 6, 4);
    directionalLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
    [directionalLight lookAt:GLKVector3Make(0, 0, 0)];
    directionalLight.enableShadow = YES;
    self.scene.mainLight = directionalLight;
    
    
    
    _light = directionalLight;
}


- (IBAction)onWireframeSwitchChanged:(UISwitch *)switcher {
    _testModel.showWireframe = switcher.on;
}


- (IBAction)onAccessorySwitchChanged:(UISwitch *)switcher  {
    _testModel.showAccessoryLine = switcher.on;
}

- (IBAction)onLightSwitchChanged:(UISwitch *)switcher {
    if (switcher.on) {
        _operator.operationObject = _light;
        
    } else {
        _operator.operationObject = _testModel;
    }
}

- (IBAction)onReset:(id)sender {
    _testModel.eulerAngles = GLKVector3Make(0, 0, 0);
    _testModel.scale = GLKVector3Make(1, 1, 1);
}


- (IBAction)onSliderChanged:(UISlider *)sender {
    CEModel *test = [_testModel childWithName:@"monkey"];
    test.material.transparency = sender.value;
}


#pragma mark - Others
- (void)recursiveSetColorForModel:(CEModel *)model {
    model.baseColor = [self randomColor];
    model.castShadows = YES;
    for (CEModel *child in model.childObjects) {
        [self recursiveSetColorForModel:child];
    }
}


- (UIColor *)randomColor {
    return [UIColor colorWithRed:arc4random() % 127 / 255.0 + 0.5
                           green:arc4random() % 127 / 255.0 + 0.5
                            blue:arc4random() % 127 / 255.0 + 0.5
                           alpha:1.0];
}

@end







