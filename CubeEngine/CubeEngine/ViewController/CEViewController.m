//
//  CEViewController.m
//  CubeEngine
//
//  Created by chance on 5/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEViewController.h"
#import "CEView_Rendering.h"
#import "CEScene_Rendering.h"
#import "CERenderManager.h"

// test headers
#import "CEShaderBuilder.h"
#import "CEDefaultProgram.h"
#import "CEModelLoader.h"
#import "CEVertexBuffer.h"
#import "CEResourceManager.h"

#define kDefaultFramesPerSecond 30
#define kDefaultMaxLightCount 4

/**
 Discussion:
 Every CEViewController has its own EAGLContex, CEScene and CERenderManager.
 No sharing resrouces between CEViewContollers.
 */

@interface CEViewController () {
    EAGLContext *_context;
    CADisplayLink *_displayLink;
    CERenderManager *_renderManager;
}

@end


@implementation CEViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initializeViewController];
    }
    return self;
}


- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super initWithCoder:coder]) {
        [self initializeViewController];
    }
    return self;
}


- (void)initializeViewController {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    _scene = [[CEScene alloc] initWithContext:_context];
    _scene.maxLightCount = [self maxLightCount];
    _scene.enableDebug = [self enableDebugMode];
    _renderManager = [[CERenderManager alloc] initWithContext:_context];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
    _displayLink.frameInterval = MAX(1, (60 / [self preferredFramesPerSecond]));
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.paused = NO;
    
//    [self onTestShaders];
//    [self testModelLoading];
}


- (void)onTestShaders {
    CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
    [shaderBuilder startBuildingNewShader];
    [shaderBuilder enableTexture:YES];
//    [shaderBuilder enableLightWithType:CELightTypeDirectional];
    [shaderBuilder enableNormalLightWithType:CELightTypeDirectional];
    CEShaderInfo *shaderInfo = [shaderBuilder build];
    
    [EAGLContext setCurrentContext:_context];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CEDefaultProgram *program = [CEDefaultProgram buildProgramWithShaderInfo:shaderInfo];
    printf("program build duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
}


- (void)testModelLoading {
//    CEModelLoader *loader = [CEModelLoader new];
//    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
//    [loader loadModelWithName:@"ram" completion:^(CEModel *model) {
//        printf("CEModelLoader load model for duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
//    }];
    
//    CEResourceDataLoader *dataLoader = [CEResourceDataLoader defaultLoader];
//    NSData *vertexData = [dataLoader loadDataWithResourceID:0x10000000];
//    NSDictionary *dataDict = [dataLoader loadDataWithResourceIDs:@[@0x10000000, @0x20000002, @0x10000002]];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    CEView *view = (CEView *)self.view;
    if (![view isKindOfClass:[CEView class]]) { //auto changed to CEView
        CEView *view = [[CEView alloc] initWithFrame:self.view.frame];
        view.autoresizingMask = self.view.autoresizingMask;
        view.backgroundColor = self.view.backgroundColor;
        for (UIView *subview in self.view.subviews) {
            [view addSubview:subview];
        }
        self.view = view;
        CEError("Auto Load CEView");
    }
    
    _scene.camera.aspect = self.view.frame.size.width / self.view.frame.size.height;
    view.opaque = YES;
    view.renderCore = _scene.renderCore;
    [view display];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self drawView:nil];
    self.paused = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.paused = YES;
}


#pragma mark - Setter & Getter

- (BOOL)isPaused {
    return _displayLink.paused;
}

- (void)setPaused:(BOOL)paused {
    _displayLink.paused = paused;
}


#pragma mark - rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat aspect1 = self.view.bounds.size.width / self.view.bounds.size.height;
    CGFloat aspect2 = self.view.bounds.size.height / self.view.bounds.size.width;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _scene.camera.aspect = MIN(aspect1, aspect2);
        
    } else {
        _scene.camera.aspect = MAX(aspect1, aspect2);
    }
}

// for iOS 8
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _scene.camera.aspect = size.width / size.height;
}


#pragma mark - Update
- (void)drawView:(id)sender {
    [self onUpdate];
    // render current scene
    [CEScene setCurrentScene:self.scene];
    [_renderManager renderCurrentScene];
    [(CEView *)self.view display];
}


- (void)onUpdate {
    // Do nothing
}


#pragma mark - Settings
- (NSInteger)preferredFramesPerSecond {
    return kDefaultFramesPerSecond;
}

- (NSInteger)maxLightCount {
    return kDefaultMaxLightCount;
}


- (BOOL)enableDebugMode {
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

@end



