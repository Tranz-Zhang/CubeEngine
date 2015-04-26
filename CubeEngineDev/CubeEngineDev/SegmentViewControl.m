//
//  SegmentView.m
//  CubeEngineDev
//
//  Created by chance on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "SegmentViewControl.h"

#define kTopBarHeight 39
#define kHideButtonWidth 50
#define kLocalWidth self.bounds.size.width
#define kLocalHeight self.bounds.size.height

@implementation SegmentViewControl {
    __weak UIView *_baseView;
    __weak UISegmentedControl *_segmentConrol;
    __weak UIView *_currentSegmentView;
}

- (instancetype)initWithBaseView:(UIView *)baseView segmentNames:(NSArray *)segmentNames {
    CGRect frame = CGRectMake(0, baseView.bounds.size.height - kTopBarHeight, baseView.bounds.size.width, kTopBarHeight);
    self = [super initWithFrame:frame];
    if (self) {
        _baseView = baseView;
        [self setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
        
        CGFloat margin = (kTopBarHeight - 29) / 2;
        UIView *barBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLocalWidth, kTopBarHeight)];
        barBackgroundView.backgroundColor = [UIColor grayColor];
        barBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self addSubview:barBackgroundView];
        
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:segmentNames];
        segment.selectedSegmentIndex = UISegmentedControlNoSegment;
        segment.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
        segment.frame = CGRectMake(margin, margin, kLocalWidth - margin - kHideButtonWidth, 29);
        segment.autoresizingMask = barBackgroundView.autoresizingMask;
        [segment addTarget:self action:@selector(onSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:segment];
        _segmentConrol = segment;
        
        UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        hideButton.frame = CGRectMake(kLocalWidth - kHideButtonWidth, 0, kHideButtonWidth, kTopBarHeight);
        hideButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        [hideButton setImage:[UIImage imageNamed:@"hide_icon"] forState:UIControlStateNormal];
        [hideButton addTarget:self action:@selector(onHide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hideButton];
    }
    return self;
}

- (void)onHide {
    _segmentConrol.selectedSegmentIndex = UISegmentedControlNoSegment;
    [self switchToNextSegmenView:nil];
}

- (void)onSegmentControlChanged:(UISegmentedControl *)segmentControl {
    if (!_baseView || !_delegate) {
        return;
    }
    UIView *nextView = [_delegate viewWithSegmentIndex:segmentControl.selectedSegmentIndex];
    nextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    nextView.frame = CGRectMake(0, kTopBarHeight, kLocalWidth, nextView.bounds.size.height);
    nextView.alpha = 0.0;
    [self addSubview:nextView];
    [self switchToNextSegmenView:nextView];
}

- (void)switchToNextSegmenView:(UIView *)nextView {
    CGFloat nextHeight = kTopBarHeight + nextView.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, _baseView.bounds.size.height - nextHeight, _baseView.bounds.size.width, nextHeight);
        _currentSegmentView.alpha = 0.0;
        nextView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        [_currentSegmentView removeFromSuperview];
        _currentSegmentView = nextView;
    }];
}


@end






