//
//  IViewControllerPort.h
//  PXBifrost_Example
//
//  Created by 胡伟伟 on 2023/7/13.
//  Copyright © 2023 huweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IViewControllerPort <NSObject>

@optional

- (UIWindow *_Nullable)keyWindow;

/**
 *  当前应用运行时的UITabBarController对象
 *
 *  @return 当前应用运行时的UITabBarController对象
 */
- (nullable UITabBarController *)mainTabBarController;

/**
 * 当前用来presend其它ViewController的ViewController
 */
- (UIViewController*_Nullable)currentVisiableRootViewController;

- (UIViewController*_Nullable)getRootViewController;

/**
 *  + (UIViewController*) currentVisiableRootViewController 扩展
 *  当currentVisiableRootViewController为MainTabBar时处理
 */
- (nullable UIViewController *)currentViewController;


- (nullable UIViewController *)currentViewControllerWithTabbar;

- (nullable UIViewController *)currentWindowRootViewController;
/**
 Safe Push VC
 
 @param vc 源vc
 @param toVc 目标vc
 @param animated 动画
 */
- (void)viewController:(nullable UIViewController *)vc
safePushViewController:(nullable UIViewController *)toVc
              animated:(BOOL)animated;


/**
 Safe Present VC
 
 @param vc presented vc
 @param animated 是否动画
 @param completion present完成回调
 */
- (void)safePresentViewController:(nullable UIViewController *)vc
                         animated:(BOOL)animated
                       completion:(void (^ __nullable)(void))completion;


/**
 Safe Portrait Push VC
 
 @param vc 源vc
 @param toVc 目标vc
 @param animated 动画
 */
- (void)viewController:(nullable UIViewController *)vc
safePortraitPushViewController:(nullable UIViewController *)toVc
              animated:(BOOL)animated;


/**
 强制旋屏
 
 @param orientation 设备方向
 */
- (void)turnToPortraitOrientation:(UIInterfaceOrientation)orientation
                       completion:(nullable dispatch_block_t)completion;

/// 旋转屏幕
/// @param orientation 设备方向
/// @param supportMask 是否需要真正的旋转，会修改全局旋转方向
/// @param completion 完成回调
- (void)turnToPortraitOrientation:(UIInterfaceOrientation)orientation
                      supportMask:(BOOL)supportMask
                       completion:(nullable dispatch_block_t)completion;


+ (BOOL)hasKindOfViewControllerInCurrentStack:(nullable Class)controller;
@end

NS_ASSUME_NONNULL_END
