//
//  CEShaderAttribute.h
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"
#import "CEVBOAttribute.h"

typedef NS_ENUM(int, CEAttributeType) {
    CEAttributeTypeNone = 0,
    CEAttributeTypeFloat = 1,
    CEAttributeTypeVector2,
    CEAttributeTypeVector3,
    CEAttributeTypeVector4,
};

CEAttributeType CEAttributeTypeWithString(NSString *attributeString);


@interface CEAttribute : CEShaderVariable

@property (nonatomic, readonly) CEAttributeType type;
@property (nonatomic, strong) CEVBOAttribute *attribute;

- (instancetype)initWithName:(NSString *)name type:(CEAttributeType)type;

@end
