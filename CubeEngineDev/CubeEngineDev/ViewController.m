//
//  ViewController.m
//  CubeEngineDev
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ViewController.h"
#import "CubeEngine.h"



@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"Cube Engine Dev: %@", CUBE_ENGINE_VERSION];
    
    GLKVector3 test = GLKVector3Make(1, 2, 3);
    
}

- (IBAction)onPushCEViewController:(id)sender {
    CEViewController *vc = [[CEViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
