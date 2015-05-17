//
//  CEBufferGroup.h
//  CubeEngine
//
//  Created by chance on 5/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"

/**
 Containing CEVertexBuffer and CEIndicesBuffer objects,
 Improve performance using vertex buffer objects (VBO)
 Smart draw call to alternate between glDrawArrays and glDrawElements
 */
@interface CEBufferGroup : CEObject

@end
