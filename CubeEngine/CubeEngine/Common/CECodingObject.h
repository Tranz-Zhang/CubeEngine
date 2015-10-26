//
//  CECodingObject.h
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 自动实现NSCoding协议，任何继承此类的子类都会自动实现NSCoding协议。支持多层继承
 */
@interface CECodingObject : NSObject <NSCoding>

/**
 从指定文件读取类
 
 @param filePath 文件路径，包括文件名称，如.../Document/[fileName]
 */
+ (instancetype)objectFromFile:(NSString *)filePath;

/** 
 保存到指定文件
 
 @param filePath 文件路径，包括文件名称，如.../Document/[fileName]
 */
- (BOOL)saveToFile:(NSString *)filePath;

@end
