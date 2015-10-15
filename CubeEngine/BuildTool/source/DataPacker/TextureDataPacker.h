//
//  TextureDataPacker.h
//  CubeEngine
//
//  Created by chance on 10/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BaseDataPacker.h"
#import "TextureInfo.h"

@interface TextureDataPacker : BaseDataPacker

- (NSString *)packTextureDataWithInfo:(TextureInfo *)textureInfo;

@end
