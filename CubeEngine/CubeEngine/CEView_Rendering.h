//
//  CEView_Rendering.h
//  CubeEngine
//
//  Created by chance on 5/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEView.h"
#import "CERenderCore.h"

@interface CEView ()

@property (nonatomic, strong) CERenderCore *renderCore;

// call this method refresh frame
- (void)display;

@end
