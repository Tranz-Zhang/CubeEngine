//
//  ModelDataPacker.m
//  CubeEngine
//
//  Created by chance on 10/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "ModelDataPacker.h"
#import "BaseDataPacker_private.h"

@implementation ModelDataPacker

- (BOOL)packModelDataDict:(NSDictionary *)dataDict {
    return [super writeData:dataDict];
}


- (NSString *)targetFileDirectory {
    return kModelDirectory;
}

@end
