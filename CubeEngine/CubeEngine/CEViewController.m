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
#import "CEShaderBool.h"
#import "CEShaderMatrix3.h"
#import "CEShaderLightInfo.h"
#import "CEShaderVariable_privates.h"
#import "CEShaderStruct_privates.h"
#import "CEShaderAttribute.h"
#import "CEShaderFileParser.h"
#import "CEUtils.h"
#import "CEShaderFileParser.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderFileInfo.h"

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
    
    [self onTestShaders];
}


- (void)onTestShaders {
//    CEShaderVariable *lightDirection = [CEShaderVariable variableWithName:@"LightDirection" type:CEGLSL_vec4 precision:CEGLSL_lowp];
//    CEShaderVariable *enabled = [CEShaderVariable variableWithName:@"Enabled" type:CEGLSL_bool precision:CEGLSL_lowp];
//    CEShaderStruct *lightInfo = [CEShaderStruct structWithName:@"LightInfo" variables:@[lightDirection, enabled]];
    CEShaderBool *enableLight = [[CEShaderBool alloc] initWithName:@"Enabled" precision:kCEPrecisionLowp];
    enableLight.boolValue = YES;
    
    CEShaderMatrix3 *mvMatrix = [[CEShaderMatrix3 alloc] initWithName:@"MVMatrix" precision:kCEPrecisionHighp];
    mvMatrix.matrix3 = GLKMatrix3Identity;
    
    CEShaderLightInfo *mainLight = [[CEShaderLightInfo alloc] initWithName:@"MainLight"];
    NSLog(@"%@\nuniform %@", [CEShaderLightInfo structDeclaration], [mainLight declaration]);
    
    CEShaderAttribute *positionAttr = [[CEShaderAttribute alloc] initWithName:@"VertexPosition" precision:kCEPrecisionMediump variableCount:4];
    NSLog(@"%@", [positionAttr declaration]);
    
//    CFAbsoluteTime startTime1 = CFAbsoluteTimeGetCurrent();
//    [self testParser];
//    NSLog(@"parse: %.5f", CFAbsoluteTimeGetCurrent() - startTime1);
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    NSData *jsonData = [NSData dataWithContentsOfFile:[CEShaderDirectory() stringByAppendingPathComponent:@"BaseLightEffect.ceshader"]];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    CEShaderFileInfo *test = [[CEShaderFileInfo alloc] initWithJsonDict:jsonDict];
    NSLog(@"load shader: %.5f", CFAbsoluteTimeGetCurrent() - startTime);
    
}


- (void)testParser {
    CEShaderFileParser *parser = [CEShaderFileParser new];
    NSString *vertexShader = [NSString stringWithContentsOfFile:[CEShaderDirectory() stringByAppendingPathComponent:@"BaseLightEffect.vert"]
                                                       encoding:NSUTF8StringEncoding error:nil];
    NSString *fragmentShader = [NSString stringWithContentsOfFile:[CEShaderDirectory() stringByAppendingPathComponent:@"BaseLightEffect.frag"]
                                                         encoding:NSUTF8StringEncoding error:nil];
    
    CEShaderFileInfo *fileInfo = [parser parseWithVertexShader:vertexShader fragmentShader:fragmentShader];
    CEShaderFunctionInfo *testFunction = [fileInfo.vertexShaderFunctions lastObject];
    NSDictionary *jsonDict = [testFunction jsonDict];
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
    BOOL isOK = [data writeToFile:[self testFilePath] atomically:YES];
    NSLog(isOK ? @"write ok" : @"write fail");
}


- (NSString *)testFilePath {
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [dir stringByAppendingPathComponent:@"test_ios"];
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



