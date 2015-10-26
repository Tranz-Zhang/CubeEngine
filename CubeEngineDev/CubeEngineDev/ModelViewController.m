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


@implementation ModelViewController {
    CEModel *_testModel;
    CELight *_light;
    ObjectOperator *_operator;
    __weak IBOutlet UISwitch *_wireframeSwitch;
    __weak IBOutlet UISwitch *_accessorySwitch;
}

- (BOOL)enableDebugMode {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.camera.position = GLKVector3Make(15, 15, 15);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
//    self.scene.camera.position = GLKVector3Make(0, 2, 5);
//    [self.scene.camera lookAt:GLKVector3Make(0, 1, 0)];
//    self.scene.camera.nearZ = 0;
//    self.scene.camera.farZ = 100;
    
//    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
//    _testModel = [CEModel modelWithObjFile:@"ram"];
////    _testModel.scale = GLKVector3Make(1.2, 1.2, 1.2);
////    _testModel.showWireframe = YES;
//    _testModel.showAccessoryLine = YES;
//    _testModel.material.specularColor = GLKVector3Make(1, 1, 1);
//    _testModel.material.shininessExponent = 20;
////    _testModel.material.diffuseTexture = nil;// @"gray_texture.png";
////    _testModel.material.normalTexture = nil;
//    [self recursiveSetColorForModel:_testModel];
//    for (CEModel *model in _testModel.childObjects) {
//        if ([model.name isEqualToString:@"leaf"]) {
//            model.material.materialType = CEMaterialAlphaTested;
//        }
//    }
    
//    printf("model loading duration: %.4f\n", CFAbsoluteTimeGetCurrent() - start);
#if 0
    CEObjFileLoader *objLoader = [[CEObjFileLoader alloc] init];
    CEModel *testRam = [[objLoader loadModelWithObjFileName:@"ram"] anyObject];
    _testModel = testRam;
    [self.scene addModel:testRam];
    
    CEModel *floorModel = [[objLoader loadModelWithObjFileName:@"floor_max"] anyObject];
    [self.scene addModel:floorModel];
    
#else
    CEModelLoader *loader = [CEModelLoader new];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [loader loadModelWithName:@"ram" completion:^(CEModel *model) {
        _testModel = model;
        _testModel.scale = GLKVector3Make(1.2, 1.2, 1.2);
        _testModel.enableShadow = YES;
        _operator.operationObject = _testModel;
        [self.scene addModel:model];
        printf("CEModelLoader load model for duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
    }];
    
    [loader loadModelWithName:@"floor_max" completion:^(CEModel *model) {
        [self.scene addModel:model];
    }];
#endif
    
#if 0
    CEModel *floorModel = [CEModel modelWithObjFile:@"floor_max"];
    floorModel.baseColor = [UIColor grayColor];
//    floorModel.castShadows = YES;
    [self.scene addModel:floorModel];
#endif
    
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

- (IBAction)_onCameraSwitchChanged:(UISwitch *)switcher {
    if (switcher.on) {
        _operator.operationObject = self.scene.camera;
        
    } else {
        _operator.operationObject = _testModel;
    }
}


- (IBAction)onReset:(id)sender {
    _testModel.eulerAngles = GLKVector3Make(0, 0, 0);
    _testModel.scale = GLKVector3Make(1, 1, 1);
}


- (IBAction)onShadowSwitchChanged:(UISwitch *)sender {
    [(CEDirectionalLight *)self.scene.mainLight setEnableShadow:sender.on];
}


#pragma mark - Others
- (void)recursiveSetColorForModel:(CEModel *)model {
    model.baseColor = [self randomColor];
    model.enableShadow = YES;
    model.material.shininessExponent = 20;
    model.material.specularColor = GLKVector3Make(0.5, 0.5, 0.5);
//    model.material.diffuseTexture = nil;
//    model.material.normalTexture = nil;
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







