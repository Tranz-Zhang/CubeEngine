//
//  CustomKeyObject.h
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//


#import "CEManagedObject.h"

@interface CustomKeyObject : CEManagedObject

BIND_OBJECT_ID(value)
@property (nonatomic, strong) NSString *value;

@property (nonatomic) int num;

@end
