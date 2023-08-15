//
//  YOYRouteManager.h
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URINavigationCenterDefine.h"
#import "YOYRouterService.h"

@class YOYRoute;

typedef void(^YOYRouteManagerHandleNextRouteBlock)(YOYRoute * _Nullable route, NSString * _Nullable path);

NS_ASSUME_NONNULL_BEGIN

@class YOYRouteManager;

@interface YOYURINavigationCenter : NSObject

@property (nullable, copy, readonly) NSString *uriScheme;

+ (instancetype)sharedObject;
/**
 * 设置URIScheme
 *
 **/
- (void)setURIScheme:(NSString *)urischeme;

- (BOOL)handleURI:(NSString *)URI;

- (BOOL)handleURI:(NSString *)URI
         complete:(nullable YOYRouteCompleteBlock)complete;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
         complete:(nullable YOYRouteCompleteBlock)complete;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info
         complete:(nullable YOYRouteCompleteBlock)complete;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info
         complete:(nullable YOYRouteCompleteBlock)complete
    hasCompatible:(BOOL)hascompatible;

- (UIViewController *)viewControllerWithURI:(NSString *)URI
                         fromViewController:(nullable UIViewController *)viewController
                                 extendInfo:(nullable NSDictionary *)info
                                   complete:(nullable YOYRouteCompleteBlock)complete;

/**
 是否能route该uri
 */
- (BOOL)canRouteURI:(NSString *)uri;

/**
 通过uri匹配到注册的uri

 @return 匹配到的注册uri，如果没匹配到，那么返回nil
 */
- (NSString *)matchRouteURI:(NSString *)uri;

/**
 通过uri匹配到注册的uri,并解析uri，生产YOYRoute对象
 
 @return YOYRoute对象，如果没匹配到，那么返回nil
 */
- (YOYRoute *)parseURI:(NSString *)uri;

@property (nonatomic, copy, nullable) YOYRouteManagerHandleNextRouteBlock handleNextRouteBlock;

@end

NS_ASSUME_NONNULL_END
