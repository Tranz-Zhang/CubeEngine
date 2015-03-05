//
//  ViewController.m
//  CubeEngineDev
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "ViewController.h"
#import "CubeEngine.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"Cube Engine Dev: %@", CUBE_ENGINE_VERSION];
}



@end
