//
//  TestCommon.h
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#ifndef FMDatabaseDevelopment_TestCommon_h
#define FMDatabaseDevelopment_TestCommon_h


#import "XCTestCase+AsyncTesting.h"

#import "CEDB.h"

#import "TestObject.h"
#import "CustomKeyObject.h"
#import "DefaultKeyObject.h"
#import "PrimaryTypeObject.h"
#import "Table.h"
#import "ConflictPropertyObject.h"
#import "CustomCodingObject.h"
#import "OrderObject_Int.h"
#import "OrderObject_String.h"
#import "NoneDBObject.h"

#endif


#define TZPrintCurrentThread() printf("current queue: %s\n", dispatch_queue_get_label(dispatch_get_current_queue()))