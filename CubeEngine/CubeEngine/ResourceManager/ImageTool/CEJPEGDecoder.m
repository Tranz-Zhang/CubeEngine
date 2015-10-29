//
//  CEJPEGDecoder.m
//  CubeEngine
//
//  Created by chance on 10/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEJPEGDecoder.h"
#import "jpeglib.h"


struct ce_error_mgr {
    struct jpeg_error_mgr pub;	/* "public" fields */
    
    jmp_buf setjmp_buffer;	/* for return to caller */
};
typedef struct ce_error_mgr * ce_error_ptr;

void ce_error_exit (j_common_ptr cinfo)
{
    /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
    ce_error_ptr myerr = (ce_error_ptr) cinfo->err;
    
    /* Always display the message. */
    /* We could postpone this until after returning, if we chose. */
    (*cinfo->err->output_message) (cinfo);
    
    /* Return control to the setjmp point */
    longjmp(myerr->setjmp_buffer, 1);
}


@implementation CEJPEGDecoder

- (CEImageDecodeResult *)decodeImageData:(NSData *)imageData {
    if (!imageData.length) return nil;
    
    struct jpeg_decompress_struct cinfo;
    struct ce_error_mgr jerr;
    JSAMPARRAY buffer;		/* Output row buffer */
    int row_stride;		/* physical row width in output buffer */

    /* We set up the normal JPEG error routines, then override error_exit. */
    cinfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.error_exit = ce_error_exit;
    /* Establish the setjmp return context for my_error_exit to use. */
    if (setjmp(jerr.setjmp_buffer)) {
        jpeg_destroy_decompress(&cinfo);
        return nil;
    }
    jpeg_create_decompress(&cinfo);
    jpeg_mem_src(&cinfo, (unsigned char *)imageData.bytes, imageData.length);
    jpeg_read_header(&cinfo, TRUE);
    jpeg_start_decompress(&cinfo);
    
    // get image info
    CEImageDecodeResult *result = [[CEImageDecodeResult alloc] init];
    result.width = cinfo.output_width;
    result.height = cinfo.output_height;
    result.bytesPerPixel = cinfo.output_components;
    result.texelType = GL_UNSIGNED_BYTE;
    switch (cinfo.out_color_space) {
        case JCS_GRAYSCALE:
            if (result.bytesPerPixel == 1) {
                result.internalFormat = GL_LUMINANCE;
                result.format = GL_LUMINANCE;
                
            } else if (result.bytesPerPixel == 2) {
                result.internalFormat = GL_LUMINANCE_ALPHA;
                result.format = GL_LUMINANCE_ALPHA;
            }
            break;
            
        case JCS_RGB:
            result.internalFormat = GL_RGB;
            result.format = GL_RGB;
            break;
            
        default:
            break;
    }
    
    // check image info
    if (!result.width ||
        !result.height ||
        !result.bytesPerPixel ||
        !result.internalFormat ||
        !result.format) {
        jpeg_finish_decompress(&cinfo);
        jpeg_destroy_decompress(&cinfo);
        return nil;
    }
    
    // get decompressed image data
    NSMutableData *sourceData = [NSMutableData data];
    row_stride = cinfo.output_width * cinfo.output_components;
    buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
    while (cinfo.output_scanline < cinfo.output_height) {
        jpeg_read_scanlines(&cinfo, buffer, 1);
        [sourceData appendBytes:buffer[0] length:row_stride];
        //        put_scanline_someplace(buffer[0], row_stride);
    }
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    
    result.data = sourceData.copy;
    
    return result;
}



@end
