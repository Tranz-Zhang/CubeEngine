//
//  CEMtlParser.m
//  CubeEngine
//
//  Created by chance on 5/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMtlParser.h"

@implementation CEMtlParser

+ (CEMtlParser *)parserWithFilePath:(NSString *)filePath {
    return [[CEMtlParser alloc] initWithFilePath:filePath];
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


- (NSArray *)parse {
    NSError *error;
    NSString *objContent = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        CEError(@"Error: %@", error);
        return nil;
    }
    
    /*
     NOTE: I use [... componentsSeparatedByString:@" "] to seperate because it's short writing,
     if something wrong, use [... componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet] instead.
     */
    NSMutableDictionary *materialDict = [NSMutableDictionary dictionary];
    CEMaterial *currentMaterial = nil;
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    for (NSString *lineContent in lines) {
        if ([lineContent hasPrefix:@"newmtl"]) {
            CEMaterial *newMaterial = [CEMaterial new];
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
            currentMaterial.diffuseTexture = valueString;
            continue;
        }
        if ([lineContent hasPrefix:@"map_Kd "]) {
            NSString *valueString = [lineContent substringFromIndex:7];
            currentMaterial.diffuseTexture = valueString;
            continue;
        }
        if ([lineContent hasPrefix:@"bump "]) {
            NSArray *values = [lineContent componentsSeparatedByString:@" "];
            currentMaterial.normalTexture = values[1];
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
