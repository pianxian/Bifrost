//
//  YOYRouterService.m
//  Bifrost
//
//  Created by pianxian on 2020/2/23.
//  Copyright © 2023  All rights reserved.
//
#import "YOYRouterService.h"
#import "YOYURINavigationCenter.h"

@implementation YOYRouterService

+ (void)handleRouteURL:(NSString *)urlName;
{
    [[YOYURINavigationCenter sharedObject] handleURI:urlName];
}

/**
 是否能route该uri
 */
+ (BOOL)canRouteURI:(NSString *)uri
{
    
    return [[YOYRouteManager defaultManager] canOpenURLstr:uri];
}

/**
 通过uri匹配到注册的uri

 @return 匹配到的注册uri，如果没匹配到，那么返回nil
 */
+ (NSString *)matchRouteURI:(NSString *)uri
{
    return [[YOYRouteManager defaultManager] matchURLstr:uri];
}

/**
 通过uri匹配到注册的uri,并解析uri，生产YOYRoute对象
 
 @return YOYRoute对象，如果没匹配到，那么返回nil
 */
+ (YOYRoute *)parseURI:(NSString *)uri
{
    return [[YOYRouteManager defaultManager] parserURLstr:uri];
}

@end
