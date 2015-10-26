//
//  OrderObject_Int.h
//  CEDatabase
//
//  Created by chance on 15/1/22.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "CEManagedObject.h"

// 用于测试存取顺序
@interface OrderObject_Int : CEManagedObject

BIND_OBJECT_ID(uniqueID)
@property (nonatomic) int uniqueID;

@end
