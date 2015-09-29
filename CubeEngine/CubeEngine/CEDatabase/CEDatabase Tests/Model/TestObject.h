//
//  TestObject.h
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-7-30.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "CEManagedObject.h"
#import "CustomKeyObject.h"

@interface SubNSObject : NSObject

@property (nonatomic, strong) NSString *someValue;

@end


@interface TestObject : CEManagedObject

//BIND_OBJECT_ID(key)
@property (nonatomic) NSInteger key;

// OC Type
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSSet *set;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSValue *value;
@property (nonatomic, strong) NSData *data;


// Mutable OC Type
//@property (nonatomic, strong) NSMutableString *mutableString;
//@property (nonatomic, strong) NSMutableArray *mutableArray;
//@property (nonatomic, strong) NSMutableDictionary *mutableDictionary;
//@property (nonatomic, strong) NSMutableSet *mutableSet;
//@property (nonatomic, strong) NSMutableData *mutableData;


// C Type
@property BOOL boolValue;
@property char charValue;
@property short shortValue;
@property int intValue;
@property long longValue;
@property long long longLongValue;

@property unsigned char uCharValue;
@property unsigned short uShortValue;
@property unsigned int uIntValue;
@property unsigned long uLongValue;
@property unsigned long long uLongLongValue;

@property double doubleValue;
@property float floatValue;

// Custom Type
@property (nonatomic, strong) CustomKeyObject *customObject; // CEManagedObject
@property (nonatomic, strong) SubNSObject *subObject; // NSObject not support


// OC structs
@property NSRange range;
@property CGPoint point;
@property CGRect rect;
@property CGSize size;


// --------  Wait to Support --------

// these type can use NSValue to encapsule
//@property UIEdgeInsets edgeInsets;
//@property const void *pointer;
//@property CGAffineTransform affineTransform;
//@property CATransform3D transform3D;


//// GLKit Type
//@property GLfloat glFloat;
//@property GLKVector2 vec2;
//@property GLKVector3 vec3;
//@property GLKVector4 vec4;

//@property (nonatomic, strong) NSDecimalNumber *decimalNumber;



@end







