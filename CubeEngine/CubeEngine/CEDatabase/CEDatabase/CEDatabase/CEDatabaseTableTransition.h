//
//  CEDatabaseTableTransition.h
//  CEDatabase
//
//  Created by chance on 14-9-29.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>


// 数据库表变更协议
@protocol CEDatabaseTableTransition <NSObject>

// 是否手动处理数据库表变更
- (BOOL)willHandleTableTransition;

- (void)onTableTransition;

@end
