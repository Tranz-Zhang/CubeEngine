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
    ObjectOperator *_operator;
    __weak IBOutlet UISwitch *_wireframeSwitch;
    __weak IBOutlet UISwitch *_accessorySwitch;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene.camera.position = GLKVector3Make(20, 20, 20);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    self.scene.camera.nearZ = 10;
    self.scene.camera.farZ = 50;
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    _testModel = [CEModel modelWithObjFile:@"test_scene"];
    _testModel.showWireframe = NO;
    _testModel.showAccessoryLine = YES;
    [self recursiveSetColorForModel:_testModel];
    
    printf("Teapot loading duration: %.4f", CFAbsoluteTimeGetCurrent() - start);
    [self.scene addModel:_testModel];
    
    _wireframeSwitch.on = _testModel.showWireframe;
    _accessorySwitch.on = _testModel.showAccessoryLine;
    
    _operator = [[ObjectOperator alloc] initWithBaseView:self.view];
    _operator.operationObject = _testModel;
}


- (IBAction)onWireframeSwitchChanged:(UISwitch *)switcher {
    _testModel.showWireframe = switcher.on;
}


- (IBAction)onAccessorySwitchChanged:(UISwitch *)switcher  {
    _testModel.showAccessoryLine = switcher.on;
}


- (IBAction)onReset:(id)sender {
    _testModel.eulerAngles = GLKVector3Make(0, 0, 0);
    _testModel.scale = GLKVector3Make(1, 1, 1);
}


- (IBAction)onParse:(id)sender {
    [_testModel recursivePrint];
//    CEModel *cube = [_testModel childWithName:@"MyPlande"];
//    cube.baseColor = [self randomColor];
}


#pragma mark - Others
- (void)recursiveSetColorForModel:(CEModel *)model {
    model.baseColor = [self randomColor];
    for (CEModel *child in model.childObjects) {
        [self recursiveSetColorForModel:child];
    }
}


- (UIColor *)randomColor {
    return [UIColor colorWithRed:arc4random() % 255 / 255.0
                           green:arc4random() % 255 / 255.0
                            blue:arc4random() % 255 / 255.0
                           alpha:1.0];
}

@end







