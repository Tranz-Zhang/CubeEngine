//
//  TextureInfo.h
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BaseDataPacker.h"

//typedef NS_ENUM(NSInteger, TextureFormat) {
//    TextureFormatUnknown = 0,
//    TextureFormatPNG,
//    TextureFormatJPEG,
//    TextureFormatPVR,
//};


@interface TextureInfo : BaseDataPacker

@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) uint32_t resourceID;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) CETextureFormat format;
@property (nonatomic, assign) uint16_t bitsPerPixel;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL hasAlpha;

+ (TextureInfo *)textureInfoWithFilePath:(NSString *)filePath;

@end
