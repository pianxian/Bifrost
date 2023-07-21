//
//  PXRouterService.h
//  Bifrost
//
//  Created by pianxian on 2020/2/23.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URINavigationCenterDefine.h"

#define RESIGN_URI(t) -(void)_UriNavigationCenterResign##t
#define goto(t) -(BOOL)goto##t:(NSDictionary *)userInfo fromViewController:(UIViewController*)viewController animation:(BOOL)animated

#define URI_GET_VIEWCONTROLLER_HANDLER(t) \
- (UIViewController *)on##t##GetViewControllerWithUserInfo:(NSDictionary *)userInfo from:(UIViewController *)viewController

#define RESIGN_ACTION(t, uriList)                            \
RESIGN_URI(t)                                                \
{                                                           \
    PXRouteHandlerBlock block = ^BOOL (PXRoute *route){                                       \
        UIViewController* vc = route.parameters[URIViewControllerKey];                  \
        NSNumber* isGetter = route.parameters[URIActionForGetViewControllerKey];        \
        if (isGetter.boolValue) {\
                NSAssert(0, @"未实现viewController的获取方法, 请用resignURIAction注册");      \
                return NO;    \
        }              \
        NSNumber* animation = route.parameters[URIAnimationKey];                        \
        return [self goto##t:route.parameters fromViewController:vc animation:animation.boolValue];                                                   \
    };                                                                          \
    [[PXRouteManager defaultManager] setObject:block forKeyedListSubscript:uriList];    \
}                                                                               \
goto(t)

#define RESIGN_URI_ACTION(t, uriList, openGetter)                 \
RESIGN_URI(t)                                                \
{                                                           \
    PXRouteHandlerBlock block = ^BOOL (PXRoute *route){                                       \
        UIViewController* vc = route.parameters[URIViewControllerKey];                  \
        NSNumber* isGetter = route.parameters[URIActionForGetViewControllerKey];        \
        if (isGetter.boolValue && openGetter) {\
            if ([self respondsToSelector:@selector(on##t##GetViewControllerWithUserInfo:from:)]) {        \
                 route.viewController = [self on##t##GetViewControllerWithUserInfo:route.parameters from:vc]; \
                 return YES;    \
            }           \
            else {        \
                 NSAssert(0, @"未实现viewController的获取方法");      \
                 return NO;          \
            }             \
        }              \
        else if (![self respondsToSelector:@selector(on##t##GetViewControllerWithUserInfo:from:)] && isGetter.boolValue && openGetter) {         \
            NSAssert(0, @"未实现viewController的获取方法");   \
            return NO;          \
        }                                                     \
        else {                                                \
            NSNumber* animation = route.parameters[URIAnimationKey];                        \
            return [self goto##t:route.parameters fromViewController:vc animation:animation.boolValue];                                                   \
        }                                                                       \
    };                                                                          \
    [[PXRouteManager defaultManager] setObject:block forKeyedListSubscript:uriList];    \
}                                                                               \
goto(t)

#define REGISTER_URI(name)  \
     _Pragma("clang diagnostic push") \
     _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
     [[MiKiURINavigationCenter sharedObject] performSelector:@selector(_UriNavigationCenterResign##name)]; \
     _Pragma("clang diagnostic pop")

#define URI(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

@interface PXRouterService : NSObject

+ (void)handleRouteURL:(NSString *)urlName;

/**
 是否能route该uri
 */
+ (BOOL)canRouteURI:(NSString *)uri;

/**
 通过uri匹配到注册的uri

 @return 匹配到的注册uri，如果没匹配到，那么返回nil
 */
+ (NSString *)matchRouteURI:(NSString *)uri;

/**
 通过uri匹配到注册的uri,并解析uri，生产PXRoute对象
 
 @return PXRoute对象，如果没匹配到，那么返回nil
 */
+ (PXRoute *)parseURI:(NSString *)uri;

@end


