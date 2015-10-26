//
//  UINibView.h
//  CubeEngineDev
//
//  Created by chance on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINibView : UIView

+ (instancetype)loadViewFromNib;

+ (instancetype)loadViewWithNibName:(NSString *)nibName;

@end
