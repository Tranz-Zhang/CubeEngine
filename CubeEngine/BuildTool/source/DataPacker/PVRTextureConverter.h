//
//  PVRTextureConverter.h
//  CubeEngine
//
//  Created by chance on 10/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVRTextureConverter : NSObject

+ (instancetype)defaultConverter;

/** 
 @return converted texture path, nil if fail
 */
- (NSString *)convertImageAtPath:(NSString *)imagePath
                  generateMipmap:(BOOL)enableMipmap;

@end
