//
//  CEAttribute.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEAttribute.h"
#import "CEShaderVariable_privates.h"
#import "CEDefines.h"

@implementation CEAttribute {
    BOOL _enabled;
}

- (void)setAttribute:(CEVBOAttribute *)attribute {
    if ([_attribute isEqualToAttribute:attribute]) {
        return;
    }
    
    if (_index < 0) {
        NSLog(@"Fail to setup tangent attribute");
        return;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_index);
        _enabled = NO;
        return;
        
    } else if (attribute.name != CEVBOAttributeTangent ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        NSLog(@"Fail to setup texture attribute");
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


- (BOOL)setupIndexWithProgram:(CEProgram *)program {
    _index = [program attributeIndex:self.name];
    return _index >= 0;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"attribute %@ %@(%d)", self.dataType, self.name, _index];
}


@end



