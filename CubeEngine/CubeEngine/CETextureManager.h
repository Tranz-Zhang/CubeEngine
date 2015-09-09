//
//  CETextureManager.h
//  CubeEngine
//
//  Created by chance on 9/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CETextureManager : NSObject

- (GLuint)loadTexture:(NSString *)textureName;

@end
