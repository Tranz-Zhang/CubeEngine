//
//  ModelViewController.m
//  CubeEngineDev
//
//  Created by chance on 15/4/7.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "ModelViewController.h"
#import "MeshGroup.h"
#import "CEObjFileLoader.h"

@implementation ModelViewController {
    CEModel *_testModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scene.camera.position = GLKVector3Make(20, 20, 20);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    _testModel = [CEModel modelWithObjFile:@"teapot"];
    printf("Teapot loading duration: %.4f", CFAbsoluteTimeGetCurrent() - start);
    _testModel.scale = GLKVector3Make(0.1, 0.1, 0.1);
    [self.scene addModel:_testModel];
}


- (IBAction)_onScaleSliderChanged:(UISlider *)slider {
    
}


- (IBAction)_onRotationSliderChanged:(UISlider *)slider {
    GLKVector3 eulerAngles = _testModel.eulerAngles;
    eulerAngles.y = slider.value * 360 - 180;
    _testModel.eulerAngles = eulerAngles;
}

@end
