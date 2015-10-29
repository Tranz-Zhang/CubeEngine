//
//  CEPNGDecoder.m
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEPNGDecoder.h"
#import "png.h"

@interface CEPNGDataProvider : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) size_t position;

@end


@implementation CEPNGDecoder

- (CEImageDecodeResult *)decodeImageData:(NSData *)imageData {
    if (!imageData.length) return nil;
    
    CEPNGDataProvider *dataHandle = [CEPNGDataProvider new];
    dataHandle.data = imageData;
    dataHandle.position = 0;
    
    png_structp structp;
    png_infop infop;
    structp = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    infop = png_create_info_struct(structp);
    png_set_read_fn(structp, (__bridge png_voidp)(dataHandle), CEPNGDecoder_onReadImageData);
    png_read_info(structp, infop);
    
    // get png info
    int png_bit_depth = png_get_bit_depth(structp, infop);
    int png_color_type = png_get_color_type(structp, infop);
    png_uint_32 width = png_get_image_width(structp, infop);
    png_uint_32 height = png_get_image_height(structp, infop);
    
    // adjust png info
    if( png_color_type == PNG_COLOR_TYPE_PALETTE ) {
        png_set_expand( structp );
    }
    if( png_color_type == PNG_COLOR_TYPE_GRAY && png_bit_depth < 8 ) {
        png_set_expand( structp );
    }
    if( png_get_valid( structp, infop, PNG_INFO_tRNS ) ) {
        png_set_expand( structp );
    }
    if( png_bit_depth == 16 ) {
        png_set_strip_16( structp );
    }
    if( png_color_type == PNG_COLOR_TYPE_GRAY || png_color_type == PNG_COLOR_TYPE_GRAY_ALPHA ) {
        png_set_gray_to_rgb( structp );
    }
    png_read_update_info( structp, infop );
    png_get_IHDR(structp, infop, &width, &height, &png_bit_depth, &png_color_type, NULL, NULL, NULL );
    
    // result
    CEImageDecodeResult *result = [[CEImageDecodeResult alloc] init];
    result.width = width;
    result.height = height;
    result.texelType = GL_UNSIGNED_BYTE;
    switch(png_color_type) {
        case PNG_COLOR_TYPE_GRAY:  {
            result.bytesPerPixel = 1;
            result.internalFormat = GL_LUMINANCE;
            result.format = GL_LUMINANCE;
            break;
        }
        case PNG_COLOR_TYPE_GRAY_ALPHA: {
            result.bytesPerPixel = 2;
            result.internalFormat = GL_LUMINANCE_ALPHA;
            result.format = GL_LUMINANCE_ALPHA;
            break;
        }
        case PNG_COLOR_TYPE_RGB: {
            result.bytesPerPixel = 3;
            result.internalFormat = GL_RGB;
            result.format = GL_RGB;
            break;
        }
        case PNG_COLOR_TYPE_RGB_ALPHA: {
            result.bytesPerPixel = 4;
            result.internalFormat = GL_RGBA;
            result.format = GL_RGBA;
            break;
        }
        default:
            break;
    }
    
    // check image info
    if (!result.width ||
        !result.height ||
        !result.bytesPerPixel ||
        !result.internalFormat ||
        !result.format) {
        png_destroy_read_struct(&structp, &infop, NULL);
        return nil;
    }
    
    // get png image data
    size_t dataSize = width * height * result.bytesPerPixel;
    unsigned char* dataBuffer = (unsigned char *)malloc(dataSize);
    png_bytep *bytep = (png_bytep *)malloc(height * sizeof(png_bytep));
    for (int i = 0; i < height; i++) {
        int n = height - ( i + 1 );
        bytep[n] = dataBuffer + (i * width * result.bytesPerPixel);
    }
    
    png_read_image(structp, bytep);
    png_read_end(structp, NULL);
    png_destroy_read_struct(&structp, &infop, NULL);
    free(bytep);
    
    result.data = [NSData dataWithBytesNoCopy:dataBuffer length:dataSize];
    return result;
}


void CEPNGDecoder_onReadImageData( png_structp structp, png_bytep bytep, png_size_t size ) {
    CEPNGDataProvider *dataHandle = (__bridge CEPNGDataProvider *) png_get_io_ptr(structp);
    if( (dataHandle.position + size) > dataHandle.data.length) {
        size = dataHandle.data.length - dataHandle.position;
    }
    [dataHandle.data getBytes:bytep range:NSMakeRange(dataHandle.position, size)];
    dataHandle.position += size;
}

@end


@implementation CEPNGDataProvider

@end

