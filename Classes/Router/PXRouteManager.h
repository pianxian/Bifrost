//
//  PXRouteManager.h
//  Bifrost
//
//  Created by pianxian on 2020/2/28.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController, PXRouteManager, PXRoute;

#define PXROUTE(p,h) [[PXRouteManager defaultManager] registerHander:h forPath:p]

typedef BOOL (^PXRouteHandlerBlock)(PXRoute *route);
typedef void (^PXRouteCompleteBlock)(PXRoute *route);
@protocol PXRouteManagerDelegate <NSObject>

@optional
- (void)routeManager:(PXRouteManager *)routeManager didOpenRoute:(PXRoute *)route forPath:(NSString *)path;

- (void)routeManager:(PXRouteManager *)routeManager handleNext:(PXRoute *)route forPath:(NSString *)path;

@end

@interface PXRouteManager : NSObject

@property (nonatomic, weak) id<PXRouteManagerDelegate> delegate;

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
- (PXRoute *)parserURL:(NSURL *)url;
- (PXRoute *)parserURLstr:(NSString *)urlstr;

/**
 *  处理url调用
 *
 *  @return 是否成功执行对应回调
 */
- (BOOL)openURL:(NSURL *)url;
- (BOOL)openURL:(NSURL *)url complete:(PXRouteCompleteBlock)complete;
- (BOOL)openURL:(NSURL *)url callbackURL:(NSURL *)callbackURL complete:(PXRouteCompleteBlock)complete;
- (BOOL)openURL:(NSURL *)url parameters:(NSDictionary *)parameters callbackURL:(NSURL *)callbackURL complete:(PXRouteCompleteBlock)complete;

- (BOOL)openURLstr:(NSString *)urlstr;
- (BOOL)openURLstr:(NSString *)urlstr complete:(PXRouteCompleteBlock)complete;
- (BOOL)openURLstr:(NSString *)urlstr parameters:(NSDictionary *)parameters complete:(PXRouteCompleteBlock)complete;

- (UIViewController *)viewControllerWithURL:(NSURL *)url
                                 parameters:(NSDictionary *)parameters
                                callbackURL:(NSURL *)callbackURL
                                   complete:(PXRouteCompleteBlock)complete;

/**
 *  支持集合快捷操作
 */
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedListSubscript:(NSArray<NSString *> *)keylist;
- (id)objectForKeyedSubscript:(NSString *)key;


/**
 *  Route路由管理
 */
- (void)registerHander:(PXRouteHandlerBlock)routeHandlerBlock forPath:(NSString *)path;
- (void)registerHander:(PXRouteHandlerBlock)routeHandlerBlock forPaths:(NSArray<NSString *> *)paths;
- (void)unregisterPath:(NSString *)path;

//
- (void)setHandlerBlock:(PXRouteHandlerBlock)block forKeyedListSubscript:(NSArray<NSString *> *)keylist;
@end
