//
//  main.m
//  BuildTool
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildToolManager.h"

/**
 BuildTool
 - copy shader resources
 - convert and copy models & textures
 */

#define ENABLE_DEBUG 1

#define CE_SHADER_STRING(text) @ #text


// commandLine: BuildTool -app ${PRODUCT_NAME} -buildDirectory ${BUILT_PRODUCTS_DIR} -engineDirectory ${SRCROOT}/../CubeEngine
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *test1 = [NSString stringWithFormat:@"%@_%@", [NSString stringWithFormat:@"1"], @"2"];
        NSString *test2 = [NSString stringWithFormat:@"%@_%@", [NSString stringWithFormat:@"1"], @"2"];
        if (test1.hash == test2.hash) {
            NSLog(@"");
        }
        
        NSMutableArray *appNameComponents = [NSMutableArray array];
        NSMutableArray *buildDirComponents = [NSMutableArray array];
        NSMutableArray *engineDirComponents = [NSMutableArray array];
        int paramType = 0;
        for (int i = 1; i < argc; i++) {
            NSString *argString = [NSString stringWithUTF8String:argv[i]];
            if ([argString hasPrefix:@"-"]) {
                if ([argString isEqualToString:@"-app"] && i + 1 < argc) {
                    paramType = 1;
                } else if ([argString isEqualToString:@"-buildDirectory"] && i + 1 < argc) {
                    paramType = 2;
                } else if ([argString isEqualToString:@"-engineDirectory"] && i + 1 < argc) {
                    paramType = 3;
                } else {
                    paramType = 0;
                }
                continue;
            }
            
            switch (paramType) {
                case 1:
                    [appNameComponents addObject:argString];
                    break;
                case 2:
                    [buildDirComponents addObject:argString];
                    break;
                case 3:
                    [engineDirComponents addObject:argString];
                    break;
                default:
                    break;
            }
        }
        printf("\n============== BuildTool ==============\n");
        if (appNameComponents.count && buildDirComponents.count && engineDirComponents.count) {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            
            BuildToolManager *manager =  [BuildToolManager new];
            manager.appName = [appNameComponents componentsJoinedByString:@" "];
            manager.buildProductDir = [[buildDirComponents componentsJoinedByString:@" "] stringByStandardizingPath];
            manager.engineProjectDir = [[engineDirComponents componentsJoinedByString:@" "] stringByStandardizingPath];
            [manager run];
            
            printf("BuildTool finish with duration: %.2fs\n", CFAbsoluteTimeGetCurrent() - startTime);
            
        } else {
            printf("ERROR: Fail to run BuildTool, checking params:\nappName: %s\nbuildDirectory: %s\nengineDirectory: %s\n",
                   appNameComponents.count ? "OK" : "Fail",
                   buildDirComponents.count ? "OK" : "Fail",
                   engineDirComponents.count ? "OK" : "Fail");
        }
        printf("\n====================================\n");
    }
    return 0;
}




