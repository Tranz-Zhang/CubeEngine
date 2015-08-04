//
//  LightViewController.m
//  CubeEngineDev
//
//  Created by chance on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "LightViewController.h"
#import "Common.h"
#import "ObjectOperator.h"
#import "SegmentViewControl.h"
#import "DirectionalLightControl.h"
#import "PointLightControl.h"
#import "SpotLightControl.h"


#define kLocalWidth self.view.bounds.size.width1
#define kLocalHeight self.view.bounds.size.height

@interface LightViewController () <SegmentViewControlDelegate> {
    SegmentViewControl *_segmentViewControl;
    NSMutableArray *_segmentViews;
    ObjectOperator *_objectOperator;
    
    CEModel *_teapotModel;
    CEModel *_floorModel;
    CEDirectionalLight *_directionalLight;
    CEPointLight *_pointLight;
    CESpotLight *_spotLight;
    
    __weak IBOutlet UISwitch *_directionalLightSwitch;
    __weak IBOutlet UISwitch *_pointLightSwitch;
    __weak IBOutlet UISwitch *_spotLightSwitch;
}


@end

@implementation LightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _objectOperator = [[ObjectOperator alloc] initWithBaseView:self.view];
    
    // setup view
    NSArray *segmentNames = @[@"D-Light", @"P-Light", @"S-Light"];
    _segmentViews = [NSMutableArray arrayWithCapacity:segmentNames.count];
    for (int i = 0; i < segmentNames.count; i++) {
        [_segmentViews addObject:[NSNull null]];
    }
    _segmentViewControl = [[SegmentViewControl alloc] initWithBaseView:self.view segmentNames:segmentNames];
    _segmentViewControl.delegate = self;
    _segmentViewControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_segmentViewControl];
    
    self.scene.backgroundColor = [UIColor whiteColor];
    self.scene.camera.position = GLKVector3Make(0, 30, 30);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
//    CEModel *templateModel = [CEModel modelWithObjFile:@"cube_triangle"];
//    templateModel.scale = GLKVector3Make(0.1, 0.1, 0.1);
//    templateModel.castShadows = YES;
//    for (int i = 0; i < 10; i++) {
//        for (int j = 0; j < 10; j ++) {
//            CEModel *cube = [templateModel duplicate];
//            cube.position = GLKVector3Make(- 10 + i * 2, -3, - 10 + j * 2);
//            [self.scene addModel:cube];
//        }
//    }
    
    _teapotModel = [CEModel modelWithObjFile:@"ram"];
    _teapotModel.showAccessoryLine = YES;
//    _teapotModel.castShadows = YES;
    _teapotModel.baseColor = [UIColor orangeColor];
    _teapotModel.material.shininessExponent = 120;
    _teapotModel.material.specularColor = GLKVector3Make(0.9, 0.9, 0.9);
//    _teapotModel.material.diffuseTexture = nil;
    [self.scene addModel:_teapotModel];
    
    _floorModel = [CEModel modelWithObjFile:@"floor_max"];
    _floorModel.baseColor = [UIColor grayColor];
    _floorModel.position = GLKVector3Make(0, -3, 0);
//    _floorModel.castShadows = YES;
//    [self.scene addModel:_floorModel];
    
    _directionalLight = [[CEDirectionalLight alloc] init];
    _directionalLight.position = GLKVector3Make(8, 8, 8);
    _directionalLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
    [_directionalLight lookAt:GLKVector3Make(0, 0, 0)];
//    _directionalLight.enableShadow = YES;
    self.scene.mainLight = _directionalLight;
    
    _pointLight = [CEPointLight new];
    _pointLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
    _pointLight.position = GLKVector3Make(-8, 15, 0);
//    self.scene.mainLight = _pointLight;
    
    _spotLight = [CESpotLight new];
    _spotLight.position = GLKVector3Make(-8, 15, 0);
    _spotLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 10);
    [_spotLight lookAt:_teapotModel.position];
//    self.scene.mainLight = _spotLight;
    
    _objectOperator.operationObject = _teapotModel;

    // update light switches
    _directionalLight.enabled = YES;
    _pointLight.enabled = YES;
    _spotLight.enabled = YES;
    _directionalLightSwitch.on = (self.scene.mainLight == _directionalLight);
    _pointLightSwitch.on = (self.scene.mainLight == _pointLight);
    _spotLightSwitch.on = (self.scene.mainLight == _spotLight);
}


- (IBAction)onReset:(id)sender {
    _teapotModel.position = GLKVector3Make(0, 0, 0);
    _teapotModel.eulerAngles = GLKVector3Make(0, 0, 0);
    _teapotModel.scale = GLKVector3Make(1, 1, 1);
    
    _directionalLight.position = GLKVector3Make(8, 0, 15);
    _directionalLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
    _directionalLight.eulerAngles = GLKVector3Make(0, 0, 0);
    
    _pointLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
    _pointLight.position = GLKVector3Make(-8, 15, 0);
}


- (IBAction)onObjectSegmentChanged:(UISegmentedControl *)segment {
    switch (segment.selectedSegmentIndex) {
        case 0:
            _objectOperator.operationObject = _teapotModel;
            break;
        case 1:
            _objectOperator.operationObject = _directionalLight;
            break;
        case 2:
            _objectOperator.operationObject = _pointLight;
            break;
        case 3:
            _objectOperator.operationObject = _spotLight;
            break;
        case 4:
            _objectOperator.operationObject = self.scene.camera;
            
        default:
            break;
    }
}


- (IBAction)onDirectionalLightSwitch:(UISwitch *)switcher {
    if (switcher.on && self.scene.mainLight != _directionalLight) {
        self.scene.mainLight = _directionalLight;
        
    } else if (!switcher.on && self.scene.mainLight == _directionalLight) {
        self.scene.mainLight = nil;
    }
}

- (IBAction)onPointLightSwitch:(UISwitch *)switcher {
    if (switcher.on && self.scene.mainLight != _pointLight) {
        self.scene.mainLight = _pointLight;
        
    } else if (!switcher.on && self.scene.mainLight == _pointLight) {
        self.scene.mainLight = nil;
    }
}

- (IBAction)onSpotLightSwitch:(UISwitch *)switcher {
    if (switcher.on && self.scene.mainLight != _spotLight) {
        self.scene.mainLight = _spotLight;
        
    } else if (!switcher.on && self.scene.mainLight == _spotLight) {
        self.scene.mainLight = nil;
    }
}


- (IBAction)onLookAt:(id)sender {
    [self.scene.mainLight lookAt:_teapotModel.position];
//    static int lookAtCount = 0;
//    switch (lookAtCount % 6) {
//        case 0:
//            [_directionalLight lookAt:GLKVector3Make(8, 18, 8)];
//            break;
//        case 1:
//            [_directionalLight lookAt:GLKVector3Make(8, -8, 8)];
//             break;
//        case 2:
//            [_directionalLight lookAt:GLKVector3Make(18, 8, 8)];
//            break;
//        case 3:
//            [_directionalLight lookAt:GLKVector3Make(-8, 8, 8)];
//            break;
//        case 4:
//            [_directionalLight lookAt:GLKVector3Make(8, 8, 18)];
//            break;
//        case 5:
//            [_directionalLight lookAt:GLKVector3Make(8, 8, -8)];
//            break;
//            
//        default:
//            break;
//    }
//    lookAtCount++;
}


#pragma mark - SegmentViewControlDelegate
- (UIView *)viewWithSegmentIndex:(NSUInteger)segmentIndex {
    UIView *nextView = _segmentViews[segmentIndex];
    if ([nextView isKindOfClass:[UIView class]]) {
        return nextView;
    }
    
    // create new views
    nextView = nil;
    switch (segmentIndex) {
        case 0: {
            DirectionalLightControl *control = [DirectionalLightControl loadViewFromNib];
            control.operationLight = _directionalLight;
            nextView = control;
            break;
        }
        case 1: {
            PointLightControl *control = [PointLightControl loadViewFromNib];
            control.operationLight = _pointLight;
            nextView = control;
            break;
        }
        case 2: {
            SpotLightControl *control = [SpotLightControl loadViewFromNib];
            control.operationLight = _spotLight;
            nextView = control;
            break;
        }
        default:
            break;
    }
    if (nextView) {
        [_segmentViews replaceObjectAtIndex:segmentIndex withObject:nextView];
    }
    return nextView;
}



@end
