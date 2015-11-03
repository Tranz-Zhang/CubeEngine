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
        NSString *cacheDirectory = [kEngineProjectDirectory stringByAppendingString:@"/BuildTool/Cache"];
        if ([self createDirectoryAtPath:cacheDirectory]) {
            _cacheDirectory = cacheDirectory;
        }
    }
    return self;
}


- (NSString *)convertImageAtPath:(NSString *)imagePath generateMipmap:(BOOL)enableMipmap {
    if (!_cacheDirectory) return nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:imagePath]) {
        NSLog(@"fail to convert image to pvr: file does not exist.");
        return nil;
    }
    
    NSString *fileName = [imagePath.lastPathComponent stringByDeletingPathExtension];
    NSString *cachePath = [_cacheDirectory stringByAppendingFormat:@"/%@.pvr", fileName];
    if ([fileManager fileExistsAtPath:cachePath]) {
        [fileManager removeItemAtPath:cachePath error:nil];
    }
    
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:@"-f"];
    [arguments addObject:@"PVR"];
    if (enableMipmap) {
        [arguments addObject:@"-m"];
    }
    [arguments addObject:@"-e"];
    [arguments addObject:@"PVRTC"];
    [arguments addObject:imagePath];
    [arguments addObject:@"-o"];
    [arguments addObject:cachePath];
    
    // example: texturetool -m -e PVRTC -f PVR -p Preview.png -o Grid16.pvr Grid16.png
    // ref:http://m.oschina.net/blog/70095
    NSTask *task = [[NSTask alloc] init];
    task.currentDirectoryPath = @"~/Desktop/texturetool";
    task.launchPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool";
    task.arguments = arguments.copy;
    [task launch];
    [task waitUntilExit];
    
    
    if ([fileManager fileExistsAtPath:cachePath]) {
        return cachePath;
    } else {
        return nil;
    }
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
