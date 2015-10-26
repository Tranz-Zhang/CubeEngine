//
//  UINibView.m
//  CubeEngineDev
//
//  Created by chance on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "UINibView.h"

@implementation UINibView


+ (UIView *)loadViewFromNib {
    NSString *nibName = NSStringFromClass([self class]);
    return [UINibView loadViewWithNibName:nibName];
}

+ (UIView *)loadViewWithNibName:(NSString *)nibName {
    UINib *nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
    NSArray *views = [nib instantiateWithOwner:nil options:nil];
    return views.lastObject;
}

@end
