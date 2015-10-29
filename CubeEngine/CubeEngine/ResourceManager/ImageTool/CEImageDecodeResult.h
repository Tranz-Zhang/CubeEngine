//
//  CEImageDecodeResult.h
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEImageDecodeResult : NSObject

@property (nonatomic, assign) GLsizei width;
@property (nonatomic, assign) GLsizei height;
@property (nonatomic, assign) GLenum format;
@property (nonatomic, assign) GLenum internalFormat;
@property (nonatomic, assign) GLenum texelType;
@property (nonatomic, assign) GLint bytesPerPixel;
@property (nonatomic, strong) NSData *data;

@end
