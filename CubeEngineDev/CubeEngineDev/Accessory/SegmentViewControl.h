//
//  SegmentView.h
//  CubeEngineDev
//
//  Created by chance on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentViewControlDelegate;
@interface SegmentViewControl : UIView

@property (nonatomic, weak) id<SegmentViewControlDelegate> delegate;

- (instancetype)initWithBaseView:(UIView *)baseView segmentNames:(NSArray *)segmentNames;

@end


@protocol SegmentViewControlDelegate <NSObject>

- (UIView *)viewWithSegmentIndex:(NSUInteger)segmentIndex;

@end
