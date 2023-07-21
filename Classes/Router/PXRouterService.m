//
//  PXRouterService.m
//  Bifrost
//
//  Created by pianxian on 2020/2/23.
//  Copyright © 2023  All rights reserved.
//
#import "PXRouterService.h"
#import "PXURINavigationCenter.h"

@implementation PXRouterService

+ (void)handleRouteURL:(NSString *)urlName;
{
    [[PXURINavigationCenter sharedObject] handleURI:urlName];
}

/**
 是否能route该uri
 */
+ (BOOL)canRouteURI:(NSString *)uri
{
    
    return [[PXRouteManager defaultManager] canOpenURLstr:uri];
}

/**
 通过uri匹配到注册的uri

 @return 匹配到的注册uri，如果没匹配到，那么返回nil
 */
+ (NSString *)matchRouteURI:(NSString *)uri
{
    return [[PXRouteManager defaultManager] matchURLstr:uri];
}

/**
 通过uri匹配到注册的uri,并解析uri，生产PXRoute对象
 
 @return PXRoute对象，如果没匹配到，那么返回nil
 */
+ (PXRoute *)parseURI:(NSString *)uri
{
    return [[PXRouteManager defaultManager] parserURLstr:uri];
}

@end
