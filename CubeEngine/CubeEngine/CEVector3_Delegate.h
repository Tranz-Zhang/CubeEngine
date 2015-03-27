//
//  CEVector3_Delegate.h
//  CubeEngine
//
//  Created by chance on 15/3/13.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEVector3.h"

@protocol CEVector3Delegate <NSObject>

- (void)onValueChanged:(CEVector3 *)vector;

@end


@interface CEVector3 ()

@property (nonatomic, weak) id<CEVector3Delegate> delegate;

@end
