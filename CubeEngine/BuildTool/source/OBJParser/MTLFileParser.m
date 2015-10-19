//
//  MTLFileParser.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "MTLFileParser.h"

@implementation MTLFileParser


+ (MTLFileParser *)parserWithFilePath:(NSString *)filePath {
    return [[MTLFileParser alloc] initWithFilePath:filePath];
}


- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
    }
    return self;
}


// values in .mtl file

// "Ka" ambient √
// "Kd" diffuse √
// "Ks" specular √
// "Ke" emission √
// "Tf" transparency √
// "illum" 灯光模式
// "d"  dissolve
// "Ns" exponent √
// "sharpness" sharpness √
// "Ni" index of refraction 折射率
// "map_Ka" mutiplied by "Ka" value
// "map_Kd" ... √ used as texture
// "map_Ks" ...
// "map_Ns" ...
// "map_Tr" ...
// "map_d"  ...
// "bump" bumb map (normal map) √


- (NSDictionary *)parse {
    NSError *error;
    NSString *objContent = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Fail to parse mtl file: %s\n", [[error localizedDescription] UTF8String]);
        return nil;
    }
    
    /*
     NOTE: I use [... componentsSeparatedByString:@" "] to seperate because it's short writing,
     if something wrong, use [... componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet] instead.
     */
    NSString *currentDirectory = [_filePath stringByDeletingLastPathComponent];
    NSMutableDictionary *materialDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *textureDict = [NSMutableDictionary dictionary];
    MaterialInfo *currentMaterial = nil;
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    for (NSString *lineContent in lines) {
        if ([lineContent hasPrefix:@"newmtl"]) {
            MaterialInfo *newMaterial = [MaterialInfo new];
            newMaterial.name = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            materialDict[newMaterial.name] =  newMaterial;
            currentMaterial= newMaterial;
        }
        if ([lineContent hasPrefix:@"Ka "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            currentMaterial.ambientColor = [self vec3FromString:valueString];
            continue;
        }
        if ([lineContent hasPrefix:@"Kd "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            currentMaterial.diffuseColor = [self vec3FromString:valueString];
            continue;
        }
        if ([lineContent hasPrefix:@"Ks "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            currentMaterial.specularColor = [self vec3FromString:valueString];
            continue;
        }
        //        if ([lineContent hasPrefix:@"Ke "]) {
        //            NSString *valueString = [lineContent substringFromIndex:3];
        //            currentMaterial.emissionColor = [self vec3FromString:valueString];
        //            continue;
        //        }
        if ([lineContent hasPrefix:@"Tf "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            GLKVector3 tf = [self vec3FromString:valueString];
            currentMaterial.transparency = (tf.x + tf.y + tf.z) / 3.0;
            continue;
        }
        if ([lineContent hasPrefix:@"Ns "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            currentMaterial.shininessExponent = [valueString floatValue];
            continue;
        }
        //        if ([lineContent hasPrefix:@"sharpness "]) {
        //            NSString *valueString = [lineContent substringFromIndex:10];
        //            currentMaterial.shininessExponent = [valueString floatValue];
        //            continue;
        //        }
        if ([lineContent hasPrefix:@"map_Kd "]) {
            NSString *valueString = [lineContent substringFromIndex:7];
            NSString *filePath = [currentDirectory stringByAppendingPathComponent:valueString];
            TextureInfo *texture = textureDict[filePath];
            if (!texture) {
                texture = [TextureInfo textureInfoWithFilePath:filePath];
                textureDict[filePath] = texture;
            }
            currentMaterial.diffuseTexture = texture;
            continue;
        }
        if ([lineContent hasPrefix:@"bump "] ||
            [lineContent hasPrefix:@"map_Bump "]) {
            NSArray *values = [lineContent componentsSeparatedByString:@" "];
            NSString *filePath = [currentDirectory stringByAppendingPathComponent:values[1]];
            TextureInfo *texture = textureDict[filePath];
            if (!texture) {
                texture = [TextureInfo textureInfoWithFilePath:filePath];
                textureDict[filePath] = texture;
            }
            currentMaterial.normalTexture = texture;
            continue;
        }
    }
    
    return [materialDict copy];
}


// @"0.1 0.1 0.1" -> vec3(0.1, 0.1, 0.1)
- (GLKVector3)vec3FromString:(NSString *)string {
    NSArray *valueStrings = [string componentsSeparatedByString:@" "];
    GLKVector3 vec3;
    for (int i = 0; i < valueStrings.count; i++) {
        if (i < 3) {
            vec3.v[i] = [valueStrings[i] floatValue];
        }
    }
    return vec3;
}


@end
