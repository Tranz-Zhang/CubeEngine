//
//  BuildToolManager.h
//  CubeEngine
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildToolManager : NSObject

@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *engineSourceDir;
@property (nonatomic, strong) NSString *productDir;

- (void)run;

@end
