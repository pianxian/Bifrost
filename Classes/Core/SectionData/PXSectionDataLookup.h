//
//  MiKiSectionDataLookup.h
//  Mediator
//
//  Created by pianxian on 2023/2/20.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MiKiSectionDataLookupBlock) (const void * _Nullable address);

NS_ASSUME_NONNULL_BEGIN

@interface PXSectionDataLookup : NSObject

+ (void)readSectionName:(const char *)sectionName
       imageProcessStep:(size_t)step
             usingBlock:(nullable MiKiSectionDataLookupBlock)usingBlock;

@end

NS_ASSUME_NONNULL_END
