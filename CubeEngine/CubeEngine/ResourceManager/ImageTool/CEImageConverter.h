//
//  CEImageConverter.h
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEImageDecodeResult.h"

@interface CEImageConverter : NSObject

+ (void)convertImageTo16Bits565:(CEImageDecodeResult *)result;
+ (void)convertImageTo16Bits5551:(CEImageDecodeResult *)result;
+ (void)convertImageTo16Bits4444:(CEImageDecodeResult *)result;

@end
