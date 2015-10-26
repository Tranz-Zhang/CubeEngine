//
//  ObjectOperationManager.h
//  CubeEngineDev
//
//  Created by tran2z on 4/26/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CEObject.h"

@interface ObjectOperator : NSObject

@property (nonatomic, weak) CEObject *operationObject;

- (instancetype)initWithBaseView:(UIView *)baseView;

@end
