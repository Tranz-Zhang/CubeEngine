//
//  PrimaryTypeObject.h
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "CEManagedObject.h"

@interface PrimaryTypeObject : CEManagedObject

BIND_OBJECT_ID(uniqueId)
@property (nonatomic) long uniqueId;
@property (nonatomic, retain) NSString *uniqueString;

@property (nonatomic) double doubleValue;

@end
