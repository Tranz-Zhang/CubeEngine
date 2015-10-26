//
//  Table.h
//  CEDatabase
//
//  Created by chance on 14-8-14.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "CEManagedObject.h"

// 测试表明冲突
@interface Table : CEManagedObject

@property (nonatomic, strong) NSString *name;


@end
