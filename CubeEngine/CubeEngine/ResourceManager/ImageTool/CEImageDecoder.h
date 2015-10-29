//
//  CEImageDecoder.h
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEImageDecodeResult.h"

@interface CEImageDecoder : NSObject

+ (instancetype)defaultPNGDecoder;
+ (instancetype)defaultJPEGDecoder;
+ (instancetype)defaultPVRDecoder;

- (CEImageDecodeResult *)decodeImageData:(NSData *)imageData;

@end
