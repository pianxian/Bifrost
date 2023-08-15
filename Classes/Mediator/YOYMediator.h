//
//  MiKiMediator.h
//  Mediator
//
//  Created by pianxian on 2023/1/13.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YOYMediator : NSObject

+ (instancetype)sharedInstance;

// 远程App调用入口
- (id __nullable)performActionWithUrl:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;


// 本地组件调用入口

/**
 *  创建对象调用实例方法
 *
 *  @param targetName Target.h
 *  @param actionName Action函数
 *  @param params     参数
 *
 *  @return some instance
 */
- (id __nullable)performTarget:(nullable NSString *)targetName action:(nullable NSString *)actionName params:(nullable id)params;

// 本地组件调用入口

/**
 *  类方法调用
 *
 *  @param className   类名
 *  @param actionName Action函数
 *  @param params     参数
 *
 *  @return some instance
 */
- (id __nullable)performClass:(nullable NSString *)className action:(nullable NSString *)actionName params:(nullable id)params;

// 本地组件调用入口

/**
 *  对象调用实例方法
 *
 *  @param targetClass   单例对象
 *  @param actionName Action函数
 *  @param params     参数
 *
 *  @return some instance
 */
- (id __nullable)performSingleTarget:(nullable id)targetClass action:(nullable NSString *)actionName params:(nullable id)params onMainThread:(BOOL )ifNeed;

// 实例对象

/**
 *  调用大于等于2个参数的函数，如果有int型，需要调用此api
 *
 *  @param targetClassName   类名
 *  @param actionName Action函数
 *  @param objects     传入参数
 *
 *  @return some instance
 */
- (id __nullable)performClass:(nullable id)targetClassName action:(nullable NSString *)actionName withObjects:(NSArray *)objects;

// 类对象

/**
 *  调用大于等于2个参数的函数，如果有int型，需要调用此api
 *
 *  @param targetClass   执行对象
 *  @param actionName Action函数
 *  @param objects     传入参数
 *
 *  @return some instance
 */
- (id __nullable)performTargetClass:(nullable id)targetClass action:(nullable NSString *)actionName withObjects:(NSArray *)objects;


@end

NS_ASSUME_NONNULL_END
