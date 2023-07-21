//
//  MiKiSectionDataLookup.m
//  Mediator
//
//  Created by pianxian on 2023/2/20.
//  Copyright © 2023  All rights reserved.
//

#import "PXSectionDataLookup.h"
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <mach-o/getsect.h>

#ifdef __LP64__
typedef uint64_t mikic_value;
typedef struct section_64 mikic_section;
typedef struct mach_header_64 mikic_mach_header;
#define sc_getsectbynamefromheader getsectbynamefromheader_64
#else
typedef uint32_t mikic_value;
typedef struct section mikic_section;
typedef struct mach_header mikic_mach_header;
#define sc_getsectbynamefromheader getsectbynamefromheader
#endif

@implementation PXSectionDataLookup

+ (void)readSectionName:(const char *)sectionName
       imageProcessStep:(size_t)step
             usingBlock:(MiKiSectionDataLookupBlock)usingBlock
{
    uint32_t imageCount = _dyld_image_count();
    for (uint32_t imageIndex = 0; imageIndex < imageCount; imageIndex++) {
        const struct mach_header *machHeader = _dyld_get_image_header(imageIndex);
        Dl_info info;
        if (0 == dladdr(machHeader, &info)) { continue; }
        
        [self readSectionName:sectionName
                    imageInfo:info
             imageProcessStep:step
                   usingBlock:usingBlock];
    }
}

+ (void)readSectionName:(const char *)sectionName
              imageInfo:(Dl_info)info imageProcessStep:(size_t)step
             usingBlock:(MiKiSectionDataLookupBlock)usingBlock
{
    void *fbase = info.dli_fbase;
    const mikic_section *section = sc_getsectbynamefromheader(fbase, "__DATA", sectionName);
    if (NULL == section) {
        return;
    }
    for (mikic_value offset = section->offset; offset < section->offset + section->size; offset += step) {
        !usingBlock ?: usingBlock(fbase + offset);
    }
}

@end
