//
//  CEModel.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModel.h"
#import "CEModel_Rendering.h"
#import "CEObjFileLoader.h"
#import "CEModelLoader.h"
#import "CEUtils.h"

@implementation CEModel {
    
}

+ (CEModel *)modelWithObjFile:(NSString *)objFileName {
    CEObjFileLoader *fileLoader =  [CEObjFileLoader new];
    return [[fileLoader loadModelWithObjFileName:objFileName] anyObject];
}



- (instancetype)initWithRenderObjects:(NSArray *)renderObjects {
    self = [super init];
    if (self) {
        _renderObjects = renderObjects;
    }
    return self;
}


- (void)dealloc {
    
}


- (NSString *)debugDescription {
    return _name;
}

#pragma mark - Setters & Getters

- (void)setBaseColor:(UIColor *)baseColor {
    _material.diffuseColor = CEVec3WithColor(baseColor);
}

- (UIColor *)baseColor {
    return _material ? CEColorWithVec3(_material.diffuseColor) : nil;
}


#pragma mark - API

- (CEModel *)childWithName:(NSString *)modelName {
    for (CEModel *child in _childObjects) {
        if ([child.name isEqualToString:modelName]) {
            return child;
        }
    }
    // search child's child
    for (CEModel *child in _childObjects) {
        CEModel *childChild = [child childWithName:modelName];
        if (childChild) {
            return childChild;
        }
    }
    return nil;
}


- (CEModel *)duplicate {
    return nil;
}


#pragma mark - Wireframe
- (void)setShowAccessoryLine:(BOOL)showAccessoryLine {
    _showAccessoryLine = showAccessoryLine;
    for (CEModel *child in _childObjects) {
        child.showAccessoryLine = showAccessoryLine;
    }
}


- (void)setShowWireframe:(BOOL)showWireframe {
    if (showWireframe != _showWireframe) {
        _showWireframe = showWireframe;
        
    }
    for (CEModel *child in _childObjects) {
        child.showWireframe = showWireframe;
    }
}


- (void)parseWireframeIndices {
    
}


- (id)generateLineIdWithBetweenPoint:(GLfloat *)p0 andPoint:(GLfloat *)p1 {
    NSMutableData *identifierData = [NSMutableData dataWithCapacity:24];
    int compareResult = p0[0] - p1[0];
    if (0 == compareResult) {
        compareResult = p0[1] - p1[1];
    }
    if (0 == compareResult) {
        compareResult = p0[2] - p1[2];
    }
    
    if (compareResult > 0) {
        [identifierData appendBytes:p0 length:12];
        [identifierData appendBytes:p1 length:12];
        
    } else {
        [identifierData appendBytes:p1 length:12];
        [identifierData appendBytes:p0 length:12];
    }
    return identifierData;
}


- (void)testAutoGenerateIndicesBuffer {
    
}


@end
