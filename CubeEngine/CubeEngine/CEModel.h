//
//  CEModel.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"

@interface CEModel : CEObject

@property (nonatomic, readonly) GLKVector3 bounds; // 模型空间大小
@property (nonatomic, assign) BOOL showWireframe; // 是否显示线框，会有额外的性能消耗，推荐调试时使用

+ (CEModel *)modelWithObjFile:(NSString *)objFileName;

@end
