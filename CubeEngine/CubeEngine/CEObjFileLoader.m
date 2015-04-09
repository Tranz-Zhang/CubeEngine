//
//  CEObjFileLoader.m
//  CubeEngine
//
//  Created by chance on 15/4/2.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEObjFileLoader.h"

@implementation CEObjFileLoader

+ (instancetype)shareLoader {
    static CEObjFileLoader *_shareInstance = nil;
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[[self class] alloc] init];
        });
    }
    return _shareInstance;
}


- (CEModel_Deprecated *)loadModelWithObjFilePath:(NSString *)filePath {
    CEModel_Deprecated *model = [CEModel_Deprecated modelWithVertexData:[self parseVertextDataWithFilePath:filePath]
                                             type:CEVertextDataType_V3];
    return model;
}

- (NSData *)parseVertextDataWithFilePath:(NSString *)filePath {
    return nil;
}

@end
