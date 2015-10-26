//
//  OrderObject_String.h
//  CEDatabase
//
//  Created by chance on 15/1/22.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "CEManagedObject.h"

// 用于测试存取顺序
@interface OrderObject_String : CEManagedObject

//BIND_OBJECT_ID(uniqueID);
@property (nonatomic, strong) NSString *uniqueID;

@end
