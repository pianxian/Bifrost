//
//  PXRouteManager.h
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URINavigationCenterDefine.h"
#import "PXRouterService.h"

@class PXRoute;

typedef void(^PXRouteManagerHandleNextRouteBlock)(PXRoute * _Nullable route, NSString * _Nullable path);

NS_ASSUME_NONNULL_BEGIN

@class PXRouteManager;

@interface PXURINavigationCenter : NSObject

@property (nullable, copy, readonly) NSString *uriScheme;

+ (instancetype)sharedObject;
/**
 * 设置URIScheme
 *
 **/
- (void)setURIScheme:(NSString *)urischeme;

- (BOOL)handleURI:(NSString *)URI;

- (BOOL)handleURI:(NSString *)URI
         complete:(nullable PXRouteCompleteBlock)complete;

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
         complete:(nullable PXRouteCompleteBlock)complete;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info
         complete:(nullable PXRouteCompleteBlock)complete;

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info
         complete:(nullable PXRouteCompleteBlock)complete
    hasCompatible:(BOOL)hascompatible;

- (UIViewController *)viewControllerWithURI:(NSString *)URI
                         fromViewController:(nullable UIViewController *)viewController
                                 extendInfo:(nullable NSDictionary *)info
                                   complete:(nullable PXRouteCompleteBlock)complete;

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
 通过uri匹配到注册的uri,并解析uri，生产PXRoute对象
 
 @return PXRoute对象，如果没匹配到，那么返回nil
 */
- (PXRoute *)parseURI:(NSString *)uri;

@property (nonatomic, copy, nullable) PXRouteManagerHandleNextRouteBlock handleNextRouteBlock;

@end

NS_ASSUME_NONNULL_END
