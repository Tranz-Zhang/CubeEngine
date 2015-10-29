//
//  CEImageDecoder.m
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEImageDecoder.h"
#import "CEPNGDecoder.h"
#import "CEJPEGDecoder.h"
#import "CEPVRDecoder.h"

@implementation CEImageDecoder

+ (instancetype)defaultPNGDecoder {
    return [[CEPNGDecoder alloc] init];
}


+ (instancetype)defaultJPEGDecoder {
    return [[CEJPEGDecoder alloc] init];
}


+ (instancetype)defaultPVRDecoder {
    return [[CEPVRDecoder alloc] init];
}


- (CEImageDecodeResult *)decodeImageData:(NSData *)imageData {
    return nil;
}


@end
