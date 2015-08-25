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
@property (nonatomic, strong) NSString *engineProjectDir;
@property (nonatomic, strong) NSString *buildProductDir;

- (void)run;

@end
