//
//  CustomCodingObject.h
//  CEDatabase
//
//  Created by chance on 14-8-15.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomCodingObject : NSObject <NSCoding>

@property (nonatomic, strong) NSString *codingName;
@property (nonatomic, strong) NSDate *codingDate;
@property (nonatomic) int value;

@end
