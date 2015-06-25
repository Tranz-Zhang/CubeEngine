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
//    self.scene.camera.projectionType = CEProjectionOrthographic;
    self.scene.camera.position = GLKVector3Make(0, 30, 30);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    CEModel *templateModel = [CEModel modelWithObjFile:@"cube_triangle"];
    templateModel.scale = GLKVector3Make(0.1, 0.1, 0.1);
    templateModel.castShadows = YES;
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j ++) {
            CEModel *cube = [templateModel duplicate];
            cube.position = GLKVector3Make(- 10 + i * 2, -3, - 10 + j * 2);
//            [self.scene addModel:cube];
        }
    }
    
    _teapotModel = [CEModel modelWithObjFile:@"teapot_smooth"];
    _teapotModel.showAccessoryLine = YES;
    _teapotModel.castShadows = YES;
    _teapotModel.baseColor = [UIColor orangeColor];
    [self.scene addModel:_teapotModel];
    
    _floorModel = [CEModel modelWithObjFile:@"floor"];
    _floorModel.baseColor = [UIColor lightGrayColor];
//    _floorModel.castShadows = YES;
    [self.scene addModel:_floorModel];
    
    _directionalLight = [[CEDirectionalLight alloc] init];
    _directionalLight.position = GLKVector3Make(8, 8, 8);
    _directionalLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
    [_directionalLight lookAt:GLKVector3Make(0, 0, 0)];
    _directionalLight.enableShadow = YES;
    [self.scene addLight:_directionalLight];
    
    _pointLight = [CEPointLight new];
    _pointLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
    _pointLight.position = GLKVector3Make(-8, 15, 0);
    [self.scene addLight:_pointLight];
    
    _spotLight = [CESpotLight new];
    _spotLight.position = GLKVector3Make(-8, 15, 0);
    _spotLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 10);
    [_spotLight lookAt:_teapotModel.position];
//    _spotLight.enableShadow = YES;
    [self.scene addLight:_spotLight];
    _objectOperator.operationObject = _teapotModel;
    
    // update light switches
    _directionalLight.enabled = YES;
    _pointLight.enabled = NO;
    _spotLight.enabled = NO;
    _directionalLightSwitch.on = _directionalLight.isEnabled;
    _pointLightSwitch.on = _pointLight.isEnabled;
    _spotLightSwitch.on = _spotLight.isEnabled;

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
    _directionalLight.enabled = switcher.on;
}

- (IBAction)onPointLightSwitch:(UISwitch *)switcher {
    _pointLight.enabled = switcher.on;
}

- (IBAction)onSpotLightSwitch:(UISwitch *)switcher {
    _spotLight.enabled = switcher.on;
}


- (IBAction)onLookAt:(id)sender {
    [_directionalLight lookAt:_teapotModel.position];
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
