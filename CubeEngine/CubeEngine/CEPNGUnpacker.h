//
//  CEPNGUnpacker.h
//  CubeEngine
//
//  Created by chance on 10/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEPNGUnpackResult : NSObject

@property (nonatomic, assign) GLsizei width;
@property (nonatomic, assign) GLsizei height;
@property (nonatomic, assign) GLenum format;
@property (nonatomic, assign) GLenum internalFormat;
@property (nonatomic, assign) GLenum texelType;
@property (nonatomic, assign) GLint bytesPrePixel;
@property (nonatomic, strong) NSData *data;

@end


@interface CEPNGUnpacker : NSObject

+ (instancetype)defaultPacker;

- (CEPNGUnpackResult *)unpackPNGData:(NSData *)pngData;

- (void)convertPNGTo16Bits565:(CEPNGUnpackResult *)result;
- (void)convertPNGTo16Bits5551:(CEPNGUnpackResult *)result;
- (void)convertPNGTo16Bits4444:(CEPNGUnpackResult *)result;

@end

