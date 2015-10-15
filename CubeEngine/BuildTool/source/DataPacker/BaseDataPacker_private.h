//
//  BaseDataPacker_private.h
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BaseDataPacker.h"
#import "CEResourceDefines.h"

@interface BaseDataPacker ()

/**
 Wirte data dictionary to file, and keep a record in a database
 
 @param dataDict @{@(ID) : NSData}
 @return file path for the packed data
 */
- (NSString *)writeData:(NSDictionary *)dataDict;

/** file directory relative to bundle path, must implemented by subclass */
- (NSString *)targetFileDirectory;

@end
