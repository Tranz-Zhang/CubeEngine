//
//  ObjectOperationManager.m
//  CubeEngineDev
//
//  Created by tran2z on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "ObjectOperator.h"
#import "Common.h"

@interface ObjectOperator ()<UIGestureRecognizerDelegate> {
    __weak UIView *_baseView;
    __weak UILabel *_infoLabel;
}

@end

@implementation ObjectOperator

- (instancetype)initWithBaseView:(UIView *)baseView
{
    self = [super init];
    if (self) {
        _baseView = baseView;
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        infoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        infoLabel.font = [UIFont systemFontOfSize:13];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.center = CGPointMake(baseView.bounds.size.width / 2, baseView.bounds.size.height / 2);
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        infoLabel.hidden = YES;
        [_baseView addSubview:infoLabel];
        _infoLabel = infoLabel;
        
        // add gesture
        UIPanGestureRecognizer *oneTouchPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTransitionPanGesture:)];
        oneTouchPanGesture.maximumNumberOfTouches = 1;
        oneTouchPanGesture.minimumNumberOfTouches = 1;
        oneTouchPanGesture.delegate = self;
        [_baseView addGestureRecognizer:oneTouchPanGesture];
        
        UIPanGestureRecognizer *twoTouchPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onRotationPanGesture:)];
        twoTouchPanGesture.delegate = self;
        twoTouchPanGesture.maximumNumberOfTouches = 2;
        twoTouchPanGesture.minimumNumberOfTouches = 2;
        [_baseView addGestureRecognizer:twoTouchPanGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
        pinchGesture.delegate = self;
        [_baseView addGestureRecognizer:pinchGesture];
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotationRollGesture:)];
        rotationGesture.delegate = self;
        [_baseView addGestureRecognizer:rotationGesture];
    }
    return self;
}


static bool isHorizontalPan;
- (void)onRotationPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [panGesture translationInView:_baseView];
        isHorizontalPan = ABS(translation.x) > ABS(translation.y);
        _infoLabel.hidden = NO;
        _infoLabel.textColor = isHorizontalPan ? ColosOfAxisY() : ColosOfAxisZ();
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:_baseView];
        [panGesture setTranslation:CGPointZero inView:_baseView];
        GLKVector3 eulerAngles = _operationObject.eulerAngles;
        if (isHorizontalPan) {
            eulerAngles.y += translation.x;
            _infoLabel.text = [NSString stringWithFormat:@"Yaw: %.2f°", eulerAngles.y];
            
        } else {
            eulerAngles.z -= translation.y;
            _infoLabel.text = [NSString stringWithFormat:@"Pitch: %.2f°", eulerAngles.z];
        }
        _operationObject.eulerAngles = eulerAngles;
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded ||
               panGesture.state == UIGestureRecognizerStateCancelled) {
        _infoLabel.hidden = YES;
    }
}


- (void)onPinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        _infoLabel.hidden = NO;
        _infoLabel.textColor = [UIColor orangeColor];
        
    } else if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        _operationObject.scale = GLKVector3MultiplyScalar(_operationObject.scale, pinchGesture.scale);;
        _infoLabel.text = [NSString stringWithFormat:@"Scale: %.2f", _operationObject.scale.x];
        pinchGesture.scale = 1;
        
    } else if (pinchGesture.state == UIGestureRecognizerStateEnded ||
               pinchGesture.state == UIGestureRecognizerStateCancelled) {
        _infoLabel.hidden = YES;
    }
}


- (void)onRotationRollGesture:(UIRotationGestureRecognizer *)rotationGesture {
    if (rotationGesture.state == UIGestureRecognizerStateBegan) {
        _infoLabel.hidden = NO;
        _infoLabel.textColor = ColorOfAxisX();
        
    } else if (rotationGesture.state == UIGestureRecognizerStateChanged) {
        GLKVector3 eulerAngles = _operationObject.eulerAngles;
        eulerAngles.x -= rotationGesture.rotation * 90;
        _operationObject.eulerAngles = eulerAngles;
        rotationGesture.rotation = 0;
        _infoLabel.text = [NSString stringWithFormat:@"Roll: %.2f°", eulerAngles.x];
        
    } else if (rotationGesture.state == UIGestureRecognizerStateEnded ||
               rotationGesture.state == UIGestureRecognizerStateCancelled) {
        _infoLabel.hidden = YES;
    }
}


#pragma mark - Transition
static int TransitionType = 0; // 1: X, 2:Y, 3:Z
- (void)onTransitionPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [panGesture locationInView:_baseView];
        CGPoint translation = [panGesture translationInView:_baseView];
        if (location.x >= _baseView.bounds.size.width - 44) {
            TransitionType = 2;
            _infoLabel.textColor = ColosOfAxisY();
            
        } else if (ABS(translation.x) >= ABS(translation.y)) {
            TransitionType = 1;
            _infoLabel.textColor = ColorOfAxisX();
            
        } else {
            TransitionType = 3;
            _infoLabel.textColor = ColosOfAxisZ();
        }
        _infoLabel.hidden = NO;
        
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:_baseView];
        [panGesture setTranslation:CGPointZero inView:_baseView];
        GLKVector3 position = _operationObject.position;
        switch (TransitionType) {
            case 1:
                position.x += translation.x / 8;
                break;
            case 2:
                position.y -= translation.y / 8;
                break;
            case 3:
                position.z += translation.y / 8;
                break;
                
            default:
                break;
        }
        _operationObject.position = position;
        _infoLabel.text = [NSString stringWithFormat:@"( %.2f, %.2f, %.2f )", position.x, position.y, position.z];
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded ||
               panGesture.state == UIGestureRecognizerStateCancelled) {
        _infoLabel.hidden = YES;
    }
}


//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    printf("TapCount: %lu\n", (unsigned long)gestureRecognizer.numberOfTouches);
//    return YES;
//}

@end





