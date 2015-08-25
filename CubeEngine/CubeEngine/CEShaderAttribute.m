//
//  CEShaderAttribute.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderAttribute.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderAttribute {
    BOOL _enabled;
}


- (instancetype)initWithName:(NSString *)name
                   precision:(NSString *)precision
               variableCount:(GLint)variableCount {
    self = [super initWithName:name precision:precision];
    if (self) {
        if (variableCount < 1 || variableCount > 4) {
            NSAssert(false, @"wrong variable count for attribute");
        }
        _variableCount = variableCount;
    }
    return self;
}

- (void)setAttribute:(CEVBOAttribute *)attribute {
    if ([_attribute isEqualToAttribute:attribute]) {
        return;
    }
    
    if (_index < 0) {
        CEWarning(@"Fail to setup tangent attribute");
        return;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_index);
        _enabled = NO;
        return;
        
    } else if (attribute.name != CEVBOAttributeTangent ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup texture attribute");
        return;
    }
    
    if (!_enabled) {
        glEnableVertexAttribArray(_index);
        _enabled = YES;
    }
    //    ... setup attribute here
    glVertexAttribPointer(_index,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return;
}


- (NSString *)declaration {
    NSString *type = _variableCount == 1 ? @"float" : [NSString stringWithFormat:@"vec%d", _variableCount];
    return [NSString stringWithFormat:@"attribute %@ %@ %@;", self.precision, type, self.name];
}


@end



