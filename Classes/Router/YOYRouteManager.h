//
//  YOYRouteManager.h
//  Bifrost
//
//  Created by pianxian on 2020/2/28.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController, YOYRouteManager, YOYRoute;

#define YOYRoute(p,h) [[YOYRouteManager defaultManager] registerHander:h forPath:p]

typedef BOOL (^YOYRouteHandlerBlock)(YOYRoute *route);
typedef void (^YOYRouteCompleteBlock)(YOYRoute *route);
@protocol YOYRouteManagerDelegate <NSObject>

@optional
- (void)routeManager:(YOYRouteManager *)routeManager didOpenRoute:(YOYRoute *)route forPath:(NSString *)path;

- (void)routeManager:(YOYRouteManager *)routeManager handleNext:(YOYRoute *)route forPath:(NSString *)path;

@end

@interface YOYRouteManager : NSObject

@property (nonatomic, weak) id<YOYRouteManagerDelegate> delegate;

+ (instancetype)defaultManager;

/**
 * 是否能处理该url
 */
- (BOOL)canOpenURLstr:(NSString *)urlstr;
- (BOOL)canOpenURL:(NSURL *)url;

/**
 * 匹配到的注册URI
 */
- (NSString *)matchURL:(NSURL *)url;
- (NSString *)matchURLstr:(NSString *)urlstr;

/**
 * 匹配到注册的URI，并解析成MiKiRoute对象
 */
- (YOYRoute *)parserURL:(NSURL *)url;
- (YOYRoute *)parserURLstr:(NSString *)urlstr;

/**
 *  处理url调用
 *
 *  @return 是否成功执行对应回调
 */
- (BOOL)openURL:(NSURL *)url;
- (BOOL)openURL:(NSURL *)url complete:(YOYRouteCompleteBlock)complete;
- (BOOL)openURL:(NSURL *)url callbackURL:(NSURL *)callbackURL complete:(YOYRouteCompleteBlock)complete;
- (BOOL)openURL:(NSURL *)url parameters:(NSDictionary *)parameters callbackURL:(NSURL *)callbackURL complete:(YOYRouteCompleteBlock)complete;

- (BOOL)openURLstr:(NSString *)urlstr;
- (BOOL)openURLstr:(NSString *)urlstr complete:(YOYRouteCompleteBlock)complete;
- (BOOL)openURLstr:(NSString *)urlstr parameters:(NSDictionary *)parameters complete:(YOYRouteCompleteBlock)complete;

- (UIViewController *)viewControllerWithURL:(NSURL *)url
                                 parameters:(NSDictionary *)parameters
                                callbackURL:(NSURL *)callbackURL
                                   complete:(YOYRouteCompleteBlock)complete;

/**
 *  支持集合快捷操作
 */
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedListSubscript:(NSArray<NSString *> *)keylist;
- (id)objectForKeyedSubscript:(NSString *)key;


/**
 *  Route路由管理
 */
- (void)registerHander:(YOYRouteHandlerBlock)routeHandlerBlock forPath:(NSString *)path;
- (void)registerHander:(YOYRouteHandlerBlock)routeHandlerBlock forPaths:(NSArray<NSString *> *)paths;
- (void)unregisterPath:(NSString *)path;

//
- (void)setHandlerBlock:(YOYRouteHandlerBlock)block forKeyedListSubscript:(NSArray<NSString *> *)keylist;
@end
