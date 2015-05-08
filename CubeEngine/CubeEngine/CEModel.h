//
//  CEModel.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"

@interface CEModel : CEObject

@property (nonatomic, readonly) GLKVector3 bounds; // the bounds in 3D space
@property (nonatomic, readonly) GLKVector3 offsetFromOrigin;
@property (nonatomic, copy) UIColor *baseColor;         // default is white
@property (nonatomic, assign) BOOL showWireframe;       // 是否显示线框，会有额外的性能消耗，推荐调试时使用
@property (nonatomic, assign) BOOL showAccessoryLine;   // 是否显示模型辅助线，可以查看模型所占空间，以及方向轴

+ (CEModel *)modelWithObjFile:(NSString *)objFileName;

@end

