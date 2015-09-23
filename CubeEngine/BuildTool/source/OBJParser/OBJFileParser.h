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

@property (nonatomic, readonly) NSString *filePath;

+ (OBJFileParser *)parserWithFilePath:(NSString *)filePath;

// @return a list of MeshInfo
- (OBJFileInfo *)parse;

+ (BOOL)addTengentDataToObjInfo:(OBJFileInfo *)objFileInfo;

@end
