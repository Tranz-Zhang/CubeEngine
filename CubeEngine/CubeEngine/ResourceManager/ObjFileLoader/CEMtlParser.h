//
//  CEMtlParser.h
//  CubeEngine
//
//  Created by chance on 5/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEMaterial.h"

@interface CEMtlParser : NSObject

@property (nonatomic, readonly) NSString *filePath;

+ (CEMtlParser *)parserWithFilePath:(NSString *)filePath;

// @return @{@"MaterialName" : CEMaterial}
- (NSDictionary *)parse;

@end
