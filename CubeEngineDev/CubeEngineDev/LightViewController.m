//
//  LightViewController.m
//  CubeEngineDev
//
//  Created by chance on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "LightViewController.h"

#import "SegmentViewControl.h"
#import "DirectionalLightControl.h"
#import "Common.h"
#import "CEDirectionalLight.h"
#import "CEPointLight.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

@interface LightViewController () <SegmentViewControlDelegate> {
    SegmentViewControl *_segmentViewControl;
    NSMutableArray *_segmentViews;
    
    CEModel *_testModel;
    CEDirectionalLight *_directionalLight;
    CEPointLight *_pointLight;
}


@end

@implementation LightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.scene.camera.position = GLKVector3Make(0, 20, 30);
    
    _testModel = [CEModel modelWithObjFile:@"teapot_smooth"];
    _testModel.showAccessoryLine = YES;
    _testModel.baseColor = [UIColor orangeColor];
    [self.scene addModel:_testModel];
    
    _directionalLight = [[CEDirectionalLight alloc] init];
    _directionalLight.position = GLKVector3Make(8, 15, 0);
    _directionalLight.scale = GLKVector3MultiplyScalar(_directionalLight.scale, 5);
    [self.scene addLight:_directionalLight];
    
    _pointLight = [CEPointLight new];
    _pointLight.scale = GLKVector3MultiplyScalar(_pointLight.scale, 5);
    _pointLight.position = GLKVector3Make(-8, 15, 0);
    _pointLight.specularItensity = 0.5;
    [self.scene addLight:_pointLight];
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
            UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kLocalWidth, 200)];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.text = @"Point Light Control";
            nextView = view;
            break;
        }
        case 2: {
            UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kLocalWidth, 200)];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.text = @"Spot Light Control";
            nextView = view;
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
