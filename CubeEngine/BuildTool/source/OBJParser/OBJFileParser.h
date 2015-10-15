//
//  ObjFileParser.h
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBJFileInfo.h"

@interface OBJFileParser : NSObject

// only get base info of obj, no data parse
+ (OBJFileInfo *)parseBaseInfoWithFilePath:(NSString *)filePath;

// data parsing
+ (OBJFileParser *)dataParser;
- (BOOL)parseDataWithFileInfo:(OBJFileInfo *)fileInfo;

@end
