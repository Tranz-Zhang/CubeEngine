//
//  main.m
//  BuildTool
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildToolManager.h"

NSString *kAppPath = nil;
NSString *kEngineProjectDirectory = nil;
NSString *kResourcesDirectory = nil;



/**
 BuildTool
 - copy shader resources
 - convert and copy models & textures
 */

#define ENABLE_DEBUG 1

#define CE_SHADER_STRING(text) @ #text


// commandLine: BuildTool -app ${PRODUCT_NAME} -buildDirectory ${BUILT_PRODUCTS_DIR} -engineDirectory ${SRCROOT}/../CubeEngine -resourcesDirectory ${SRCROOT}/Resources
// scheme: BuildTool -app DEBUG -buildDirectory ${SRCROOT}/BuildTool -engineDirectory ${SRCROOT}/../CubeEngine
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
        NSMutableArray *resourcesDirComponents = [NSMutableArray array];
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
                } else if ([argString isEqualToString:@"-resourcesDirectory"] && i + 1 < argc) {
                    paramType = 4;
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
                case 4:
                    [resourcesDirComponents addObject:argString];
                    break;
                default:
                    break;
            }
        }
        
        // setup app path
        if (!kAppPath && buildDirComponents.count && appNameComponents.count) {
            NSString *appName = [appNameComponents componentsJoinedByString:@" "];
            NSString *productPath = [[buildDirComponents componentsJoinedByString:@" "] stringByStandardizingPath];
            kAppPath = [productPath stringByAppendingFormat:@"/%@.app", appName];
        }
        
        // setup project directory
        if (!kEngineProjectDirectory && engineDirComponents.count) {
            kEngineProjectDirectory = [[engineDirComponents componentsJoinedByString:@" "] stringByStandardizingPath];
        }
        
        // setup resources directoy
        if (!kResourcesDirectory && resourcesDirComponents.count) {
            kResourcesDirectory = [[resourcesDirComponents componentsJoinedByString:@" "] stringByStandardizingPath];
        }
        
        NSLog(@"\n============================ BuildTool ============================\n");
        if (kAppPath && kEngineProjectDirectory && kResourcesDirectory) {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            
            BuildToolManager *manager =  [BuildToolManager new];
            [manager run];
            NSLog(@"BuildTool finish with duration: %.2fs\n", CFAbsoluteTimeGetCurrent() - startTime);
            
        } else {
            NSLog(@"ERROR: Fail to run BuildTool, checking params:\nappPath: %s\nengine directory: %s\nresource directory: %s\n",
                   kAppPath ? "OK" : "Fail",
                   kEngineProjectDirectory ? "OK" : "Fail",
                   kResourcesDirectory ? "OK" : "Fail");
            assert(0);
        }
        NSLog(@"\n===================================================================\n");
    }
    return 0;
}




