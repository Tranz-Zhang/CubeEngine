//
//  CEJsonObjectProtocol.h
//  CubeEngine
//
//  Created by chance on 8/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CEJsonCoding <NSObject>
@required
- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict;
- (NSDictionary *)jsonDict;

@end
