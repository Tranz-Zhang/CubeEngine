//
//  CEObjParser.h
//  CubeEngine
//
//  Created by chance on 5/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEObjMeshInfo.h"

@interface CEObjParser : NSObject

@property (nonatomic, readonly) NSString *filePath;
@property (nonatomic, readonly) NSString *mtlFileName;

+ (CEObjParser *)parserWithFilePath:(NSString *)filePath;

// @return a list of CEObjMeshGroup
- (NSArray *)parse;

@end
