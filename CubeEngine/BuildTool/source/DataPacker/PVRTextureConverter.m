//
//  PVRTextureConverter.m
//  CubeEngine
//
//  Created by chance on 10/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "PVRTextureConverter.h"

@implementation PVRTextureConverter {
    NSString *_cacheDirectory;
}

+ (instancetype)defaultConverter {
    static PVRTextureConverter *_shareInstance;
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[[self class] alloc] init];
        });
    }
    return _shareInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *cacheDirectory = [kEngineProjectDirectory stringByAppendingString:@"\\BuildTool\\Cache"];
        if ([self createDirectoryAtPath:cacheDirectory]) {
            _cacheDirectory = cacheDirectory;
        }
    }
    return self;
}


- (NSString *)convertImageAtPath:(NSString *)imagePath {
    if (!_cacheDirectory) return nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:imagePath]) {
        NSLog(@"fail to convert image to pvr: file does not exist.");
        return nil;
    }
    
    NSTask *task = [[NSTask alloc] init];
//    [task setStandardOutput:[NSPipe pipe]];
    task.currentDirectoryPath = @"~/Desktop/texturetool";
    task.launchPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool";
    // -f PVR -e PVRTC ./Brick.png -o ./Brick.pvr
    //    task.arguments = @[@"-f", @"PVR", @"-e", @"PVRTC", @"~/Desktop/texturetool/Brick.png", @"-o", @"~/Desktop/texturetool/Brick_v.pvr"];
    task.arguments = @[@"-f", @"PVR", @"-e", @"PVRTC", @"~/Desktop/texturetool/Brick.png", @"-o", @"/Users/chance/My Development/cube-engine/CubeEngine/BuildTool/Brick_v.pvr"];
    [task launch];
    [task waitUntilExit];
    
    return nil;
}


- (BOOL)createDirectoryAtPath:(NSString *)directoryPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
        NSLog(@"Create directory %@ at:%@\n", isOK ? @"OK" : @"FAIL", directoryPath);
        return isOK;
    }
    return YES;
}

@end
