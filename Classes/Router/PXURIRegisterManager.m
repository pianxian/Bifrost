//
//  MiKiURIRegisterManager.m
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import "PXURIRegisterManager.h"
#import "URINavigationCenterDefine.h"
#import <objc/runtime.h>

@implementation PXURIRegisterManager

static BOOL s_inited;
+ (BOOL)inited
{
    return s_inited;
}

+ (void)setInited:(BOOL)inited
{
    s_inited = inited;
}


+ (void)registerURINavisAuto
{
    [PXURIRegisterManager registerUrlNaviForClass:[PXURINavigationCenter class]];
}

#pragma mark -private methods
+ (void)registerUrlNaviForClass:(Class)clazz
{
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clazz, &methodCount);
    if (methods && methodCount > 0) {
        PXURINavigationCenter *shareObj = [PXURINavigationCenter sharedObject];
        for (unsigned int i = 0; i < methodCount; i++) {
            SEL selector = method_getName(methods[i]);
            NSString *selectorName = NSStringFromSelector(selector);
            if ([selectorName hasPrefix:ResignPrefixIndentifier]) {
                SEL selector = NSSelectorFromString(selectorName);
                IMP imp = [shareObj methodForSelector:selector];
                void (*func)(id, SEL) = (void *)imp;
                func(shareObj, selector);
            }
        }
    }

    if (methods) {
        free(methods);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:URIRouteRegisterKey object:nil];
}

@end
