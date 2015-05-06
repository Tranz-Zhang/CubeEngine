//
//  CEViewController.h
//  CubeEngine
//
//  Created by chance on 5/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEView.h"
#import "CEModel.h"
#import "CEScene.h"

@interface CEViewController : UIViewController

@property (nonatomic, readonly) CEScene *scene;

/**
  This property determines whether to pause or resume drawing
  at the rate defined by the framesPerSecond property.
  Initial value is NO.
 */
@property (nonatomic, getter=isPaused) BOOL paused;

// This method is called to update contents per frame
- (void)onUpdate;


#pragma mark - Settings
// overwrite these methods to return your settings

/**
 This property contains the desired frames per second rate for
 drawing. The default is 30.
 */
- (NSInteger)preferredFramesPerSecond;

/**
 Indicates the max number of light object in current scene.
 Default is 4.
 */
- (NSInteger)maxLightCount;

/**
 Under debug mode, CEModel can show wireframe and bounds, CELight is displayed as model object.
 Default is depending on whether DEBUG is defined
 */
- (BOOL)enableDebugMode;

@end
