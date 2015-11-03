//
//  RenderViewController.m
//  CubeEngineDev
//
//  Created by chance on 11/3/15.
//  Copyright © 2015 ByChance. All rights reserved.
//

#import "RenderViewController.h"
#import "ObjectOperator.h"

#define kActionSheetTag_models 1
#define kActionSheetTag_mipmap 2

@interface RenderViewController ()<UIActionSheetDelegate> {
    NSArray *_allModelNames;
    CEModel *_model;
    ObjectOperator *_operator;
}
@property (weak, nonatomic) IBOutlet UISwitch *wireframeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *accessorySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shadowSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *operateObjectSegment;
@property (weak, nonatomic) IBOutlet UIButton *mipmapButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lightSegment;

@end


@implementation RenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _operator = [[ObjectOperator alloc] initWithBaseView:self.view];
    self.wireframeSwitch.on = NO;
    self.accessorySwitch.on = NO;
    self.shadowSwitch.on = YES;
    
    self.scene.camera.position = GLKVector3Make(15, 15, 15);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    [[CEModelLoader defaultLoader] loadModelWithName:@"floor_max" completion:^(CEModel *model) {
        [self.scene addModel:model];
    }];
    
    self.lightSegment.selectedSegmentIndex = 2;
    [self onChangeLightType:self.lightSegment];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Lower Controls

- (IBAction)onChangeModel:(UIButton *)sender {
    if (!_allModelNames) {
        _allModelNames = [[CEModelLoader defaultLoader] allModelNames];
    }
    if (!_allModelNames.count) {
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Models" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = kActionSheetTag_models;
    for (NSString *modelName in _allModelNames) {
        [actionSheet addButtonWithTitle:modelName];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle: @"Cancel"];
    [actionSheet showInView:self.view];
}


- (IBAction)onChangeMipmap:(UIButton *)sender {
    
}


// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (actionSheet.tag == kActionSheetTag_models) {
        NSString *modelName = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (!modelName.length || [modelName isEqualToString:_model.name]) {
            return;
        }
        [self.scene removeModel:_model];
        [[CEModelLoader defaultLoader] loadModelWithName:modelName completion:^(CEModel *model) {
            if (model) {
                _model = model;
                _model.showWireframe = self.wireframeSwitch.on;
                _model.showAccessoryLine = self.accessorySwitch.on;
                _model.enableShadow = self.shadowSwitch.on;
                _operator.operationObject = _model;
                _operateObjectSegment.selectedSegmentIndex = 0;
                [self.scene addModel:_model];
                
            } else {
                NSString *message = [NSString stringWithFormat:@"Fail to load model: %@", modelName];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        }];
    
    } else if (actionSheet.tag == kActionSheetTag_mipmap) {
        
    }
}



- (IBAction)onChangeControlObject:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            _operator.operationObject = _model;
            break;
        case 1:
            _operator.operationObject = self.scene.mainLight;
            break;
        case 2:
            _operator.operationObject = self.scene.camera;
            break;
        default:
            break;
    }
}


- (IBAction)onChangeLightType:(UISegmentedControl *)sender {
    CELight *light = nil;
    switch (sender.selectedSegmentIndex) {
        case 1: {// directional light
            CEDirectionalLight *directionalLight = [CEDirectionalLight new];
            directionalLight.position = GLKVector3Make(4, 6, 4);
            directionalLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
            [directionalLight lookAt:GLKVector3Make(0, 0, 0)];
            directionalLight.enableShadow = self.shadowSwitch.on;
            light = directionalLight;
            break;
        }
        case 2: {// point light
            CEPointLight *pointLight = [CEPointLight new];
            pointLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
            pointLight.position = GLKVector3Make(6, 8, 0);
//            pointLight.attenuation = 0.5;
            light = pointLight;
            break;
        }
        case 3: { // spot light
            CESpotLight *spotLight = [CESpotLight new];
            spotLight.position = GLKVector3Make(6, 8, 0);
            spotLight.scale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 5);
            [spotLight lookAt:_model.position];
            light = spotLight;
            break;
        }
        case 0: // none
        default:
            break;
    }
    self.scene.mainLight = light;
    if (light) {
        _operator.operationObject = light;
        _operateObjectSegment.selectedSegmentIndex = 1;
    }
}


- (IBAction)onWireframeSwitch:(UISwitch *)sender {
    _model.showWireframe = sender.on;
}


- (IBAction)onAccessorySwitch:(UISwitch *)sender {
    _model.showAccessoryLine = sender.on;
}


- (IBAction)onShadowMapSwitch:(UISwitch *)sender {
    _model.enableShadow = sender.on;
    if ([self.scene.mainLight isKindOfClass:[CEShadowLight class]]) {
        [((CEShadowLight *)self.scene.mainLight) setEnableShadow:sender.on];
    }
}




//- (IBAction)onChangeMipmap:(UISegmentedControl *)sender {
//    switch (sender.selectedSegmentIndex) {
//        case 0:
//            _model.mipmapQuality = CETextureMipmapNone;
//            break;
//        case 1:
//            _model.mipmapQuality = CETextureMipmapLow;
//            break;
//        case 2:
//            _model.mipmapQuality = CETextureMipmapNormal;
//            break;
//        case 3:
//            _model.mipmapQuality = CETextureMipmapHigh;
//            break;
//        default:
//            _model.mipmapQuality = CETextureMipmapNone;
//            break;
//    }
//}


@end
