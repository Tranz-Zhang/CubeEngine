//
//  ConflictPropertyObject.h
//  CEDatabase
//
//  Created by chance on 14-8-14.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "CEManagedObject.h"

@interface ConflictPropertyObject : CEManagedObject

@property (nonatomic, strong) NSString *table;
@property (nonatomic, strong) NSString *where;
@property (nonatomic, strong) NSString *query;

@end
