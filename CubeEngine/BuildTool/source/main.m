//
//  main.m
//  BuildTool
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildToolManager.h"

// BuildTool -app CubeEngineDev -d ${BUILT_PRODUCTS_DIR}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // get engine dir
        NSString *engineDir = [NSString stringWithUTF8String:argv[0]];
        engineDir = [engineDir substringToIndex:engineDir.length - [@"/BuildTool/BuildTool" length]];
        engineDir = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:engineDir];
        
        NSString *appName;
        NSString *productDir;
        for (int i = 1; i < argc; i++) {
            NSString *argString = [NSString stringWithUTF8String:argv[i]];
            if ([argString isEqualToString:@"-app"] && i + 1 < argc) {
                appName = [NSString stringWithUTF8String:argv[i + 1]];
            }
            if ([argString isEqualToString:@"-d"] && i + 1 < argc) {
                productDir = [NSString stringWithUTF8String:argv[i + 1]];
            }
        }
        
        if (appName.length && productDir.length) {
            BuildToolManager *manager =  [BuildToolManager new];
            manager.appName = appName;
            manager.productDir = productDir;
            manager.engineSourceDir = engineDir.stringByStandardizingPath;
            [manager run];
            
        } else {
            printf("ERROR: Fail to run BuildTool\n");
        }
    }
    return 0;
}
