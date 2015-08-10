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


@end

