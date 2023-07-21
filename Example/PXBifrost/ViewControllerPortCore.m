//
//  ViewControllerPortCore.m
//  PXBifrost_Example
//
//  Created by 胡伟伟 on 2023/7/13.
//  Copyright © 2023 huweiwei. All rights reserved.
//

#import "ViewControllerPortCore.h"
#import <PXBifrost/PXCoreService.h>
#import "INavigationController.h"
#import <YYCategories/NSObject+YYAdd.h>

@implementation ViewControllerPortCore
PX_CORE_REGISTER(IViewControllerPort, ViewControllerPortCore)

IMPLEMENT_COREPROTOCOL

- (UIWindow *_Nullable)keyWindow;
{
    if (@available(iOS 13.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        if (array.firstObject != nil) {
            UIWindowScene *windowScene = (UIWindowScene *)array.firstObject;
            id<UIWindowSceneDelegate> delegate = (id<UIWindowSceneDelegate>)windowScene.delegate;
            UIWindow *mainWindow = delegate.window;
            if (mainWindow) {
                return mainWindow;
            }
        }
    }
    return UIApplication.sharedApplication.delegate.window;
}
/**
 * 当前应用运行时的UITabBarController对象
 *
 * @return当前应用运行时的UITabBarController对象
 */
- (UITabBarController *)mainTabBarController
{
    
    Class tabBar = NSClassFromString(@"BBATabBarController");
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]] || [rootViewController isKindOfClass:tabBar]) {
        return (UITabBarController *)rootViewController;
    }
    return nil;
}

/**
 * 当前用来presend其它ViewController的ViewController
 */
- (UIViewController *)currentVisiableRootViewController
{
    __block UIViewController *result = nil;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = PXGetCoreI(IViewControllerPort).keyWindow;
    //手百自定义的window，原逻辑会出问题，先这么改看看效果
    //    if (topWindow.windowLevel != UIWindowLevelNormal) {
    if (topWindow.windowLevel == UIWindowLevelAlert || topWindow.windowLevel == UIWindowLevelStatusBar) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (topWindow in windows) {
            if (topWindow.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    NSArray *windowSubviews = [topWindow subviews].copy;
    [windowSubviews
     enumerateObjectsWithOptions:NSEnumerationReverse
     usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *rootView = obj;
        if ([NSStringFromClass([rootView class]) isEqualToString:@"UITransitionView"]) {
            NSArray *aSubViews = rootView.subviews;
            [aSubViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *tempView = obj;
                id nextResponder = [tempView nextResponder];
                if ([nextResponder isKindOfClass:[UIViewController class]]) {
                    result = nextResponder;
                    *stop = YES;
                }
            }];
            *stop = YES;
        } else {
            
            id nextResponder = [rootView nextResponder];
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                result = nextResponder;
                *stop = YES;
            }
        }
    }];
    Class tabBar = NSClassFromString(@"BBATabBarController");
    if (result == nil && [topWindow respondsToSelector:@selector(rootViewController)] &&
        topWindow.rootViewController != nil) {
        if ([topWindow.rootViewController isKindOfClass:[UITabBarController class]] || [topWindow.rootViewController isKindOfClass:tabBar]) {
            result = topWindow.rootViewController;
        }else{
            NSLog(@"%@", NSStringFromClass(topWindow.class),NSStringFromClass(topWindow.rootViewController.class));
        }
    }else{
        NSLog(@"%@", NSStringFromClass(topWindow.class),NSStringFromClass(topWindow.rootViewController.class));
    }
    return result ?: PXGetCoreI(IViewControllerPort).keyWindow.rootViewController;
}

- (UIViewController *)getRootViewController
{
    
    __block UIViewController *result = nil;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = PXGetCoreI(IViewControllerPort).keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (topWindow in windows) {
            if (topWindow.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
    NSArray *windowSubviews = [topWindow subviews];
    [windowSubviews
     enumerateObjectsWithOptions:NSEnumerationReverse
     usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *rootView = obj;
        
        if ([NSStringFromClass([rootView class]) isEqualToString:@"UITransitionView"]) {
            
            NSArray *aSubViews = rootView.subviews;
            
            [aSubViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *tempView = obj;
                
                id nextResponder = [tempView nextResponder];
                
                if ([nextResponder isKindOfClass:[UIViewController class]]) {
                    result = nextResponder;
                    *stop = YES;
                }
            }];
            *stop = YES;
        } else {
            
            id nextResponder = [rootView nextResponder];
            
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                result = nextResponder;
                *stop = YES;
            }
        }
    }];
    
    if (result == nil && [topWindow respondsToSelector:@selector(rootViewController)] &&
        topWindow.rootViewController != nil) {
        result = topWindow.rootViewController;
    }else{
        NSLog(@"%@ %@", NSStringFromClass(result.class), NSStringFromClass(topWindow.class),NSStringFromClass(topWindow.rootViewController.class));
    }
    
    return result;
}

/**
 *  + (UIViewController*) currentVisiableRootViewController 扩展
 *  当currentVisiableRootViewController为MainTabBar时处理
 */
- (UIViewController *)currentViewController
{
    
    UIViewController *vc = [self currentVisiableRootViewController];
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc topViewController];
    }
    NSLog(@"ViewControllerPort currentView222 %@",NSStringFromClass(vc.class));
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UIViewController *tVc = [(UITabBarController *)vc selectedViewController];
        if ([tVc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)tVc topViewController];
            NSLog(@"ViewControllerPort currentView33 %@",NSStringFromClass(vc.class));
        } else {
            vc = tVc;
            NSLog(@"ViewControllerPort currentView444 %@",NSStringFromClass(vc.class));
        }
    }
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    NSLog(@"ViewControllerPort currentView55 %@",NSStringFromClass(vc.class));
    return vc;
}

- (UIViewController *)currentViewControllerWithTabbar
{
    UIViewController *vc = [self currentVisiableRootViewController];
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc topViewController];
    }
    if ([vc isKindOfClass:[UITabBarController class]] ) {
        UITabBarController *homeViewController = (UITabBarController *)vc;
        UITabBarController *controller = homeViewController;
        
        UIViewController *tVc = [controller selectedViewController];
        if ([tVc isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *nav = (UINavigationController *)tVc;
            
            if (![nav.viewControllers indexOfObject:nav.topViewController]) {
                vc = [self getRootViewController];
            } else {
                vc = [(UINavigationController *)tVc topViewController];
            }
        } else {
            vc = tVc;
        }
    }
    
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    
    return vc;
}

- (nullable UIViewController *)currentWindowRootViewController
{
    __block UIViewController *result = nil;
    UIWindow *topWindow = PXGetCoreI(IViewControllerPort).keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (topWindow in windows) {
            if (topWindow.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    if (result == nil && [topWindow respondsToSelector:@selector(rootViewController)] &&
        topWindow.rootViewController != nil) {
        result = topWindow.rootViewController;
    }else{
        NSLog(NSStringFromClass(result.class), NSStringFromClass(topWindow.class),NSStringFromClass(topWindow.rootViewController.class));
    }
    return result;
}
/**
 Safe Push VC
 
 @param vc 源vc
 @param toVc 目标vc
 @param animated 动画
 */
- (void)viewController:(UIViewController *)vc
safePushViewController:(UIViewController *)toVc
              animated:(BOOL)animated
{
    
    if (!toVc) {
        NSLog(@"%s toVC is nil!!!", __func__);
        return;
    }
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        
        [(UINavigationController *)vc pushViewController:toVc animated:animated];
        
        return;
    }
    
    BOOL shouldPush = NO;
    __weak UIViewController *tempController = vc;
    do {
        if (tempController == tempController.navigationController.topViewController) {
            shouldPush = YES;
            
            break;
        } else {
            tempController = tempController.parentViewController;
        }
        
    } while (tempController.parentViewController);
    
    if (shouldPush) {
        [vc.navigationController pushViewController:toVc animated:animated];
    } else {
        NSLog(@"%s should push is no,push failed!!!tempController is %@", __func__,NSStringFromClass([tempController class]));
    }
}

- (void)safePresentViewController:(UIViewController *)vc
                         animated:(BOOL)animated
                       completion:(void (^__nullable)(void))completion
{
    if ([vc isKindOfClass:[UINavigationController class]] || vc.navigationController) {
        vc.modalPresentationStyle =  UIModalPresentationFullScreen;
        [[PXGetCoreI(IViewControllerPort) currentViewController] presentViewController:vc
                                                                                animated:animated
                                                                              completion:completion];
    }
    else {
        UINavigationController *navigationVC = [[PXGetClassI(INavigationController) alloc] initWithRootViewController:vc];
        [navigationVC setNavigationBarHidden:YES animated:YES];
        navigationVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[PXGetCoreI(IViewControllerPort) currentViewController] presentViewController:navigationVC
                                                                                animated:animated
                                                                              completion:completion];
    }
}

/**
 Safe Portrait Push VC
 @param vc 源vc
 @param toVc 目标vc
 @param animated 动画
 */
- (void)viewController:(UIViewController *)vc
safePortraitPushViewController:(UIViewController *)toVc
              animated:(BOOL)animated
{
    dispatch_block_t safePushBlock = ^{
        [self viewController:vc safePushViewController:toVc animated:animated];
    };
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [self turnToPortraitOrientation:UIInterfaceOrientationPortrait
                                 fromVC:vc
                             completion:safePushBlock];
    } else {
        safePushBlock();
    }
}

- (void)turnToPortraitOrientation:(UIInterfaceOrientation)orientation
                       completion:(dispatch_block_t)completion
{
    [self miki_AttemptRotationToInterfaceOrientation:orientation
                                         supportMask:true
                                          completion:completion];
}

- (void)turnToPortraitOrientation:(UIInterfaceOrientation)orientation
                      supportMask:(BOOL)supportMask
                       completion:(dispatch_block_t)completion
{
    [self miki_AttemptRotationToInterfaceOrientation:orientation supportMask:supportMask completion:completion];
}

- (void)turnToPortraitOrientation:(UIInterfaceOrientation)orientation
                           fromVC:(UIViewController *)fromVC
                       completion:(dispatch_block_t)completion
{
    [self miki_AttemptRotationToInterfaceOrientation:orientation
                                         supportMask:true
                                          completion:completion];
}

- (void)miki_AttemptRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation
                                       supportMask:(BOOL)supportMask
                                        completion:(dispatch_block_t)completion
{
//    UIViewController *currentViewController = [self currentViewController];
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskPortrait;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        mask = UIInterfaceOrientationMaskLandscapeLeft;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        mask = UIInterfaceOrientationMaskLandscapeRight;
    }
    NSLog(@"屏幕旋转  orientation:%zd supportMask:%@",orientation,supportMask?@"YES":@"NO");
    if (supportMask) {
        [(NSObject *)UIApplication.sharedApplication.delegate performSelectorWithArgs:@selector(setInterfaceOrientationMask:), mask];
        /*
        if (@available(iOS 16.0, *)) {
            [currentViewController setNeedsUpdateOfSupportedInterfaceOrientations];
            [currentViewController.navigationController setNeedsUpdateOfSupportedInterfaceOrientations];
            NSArray <UIScene *>*connectScenes = [UIApplication.sharedApplication connectedScenes].allObjects;
            UIWindowScene *scene = (UIWindowScene *)connectScenes.firstObject;
            UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask];
            [scene requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
                MiKiXLOG_ERROR("", @"error:%@", error);
            }];
            !completion ?: completion();
            return;
        }
         */
    }
    UIDeviceOrientation deviceOri = UIDeviceOrientationPortrait;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        deviceOri = UIDeviceOrientationLandscapeRight;
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight ){
        deviceOri = UIDeviceOrientationLandscapeLeft;
    }
    if (![[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    SEL sel = @selector(setOrientation:);
    NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:sel]];
    [invoc setSelector:sel];
    [invoc setTarget:[UIDevice currentDevice]];
    [invoc setArgument:&deviceOri atIndex:2];
    [invoc invoke];
    if (@available(iOS 16.0, *)) {
        [self.currentViewController setNeedsUpdateOfSupportedInterfaceOrientations];
    }
    else {
        [UIViewController attemptRotationToDeviceOrientation];
    }
    !completion ?: completion();
}


+ (BOOL)hasKindOfViewControllerInCurrentStack:(Class)controller
{
    UITabBarController *mainTabbarController = [PXGetCoreI(IViewControllerPort) mainTabBarController];
    
    __block BOOL result = NO;
    [mainTabbarController.viewControllers
     enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:controller]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    if (result) {
        return result;
    }
    
    UIViewController *tVc = [mainTabbarController selectedViewController];
    if ([tVc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVc = (UINavigationController *)tVc;
        [navVc.viewControllers
         enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:controller]) {
                result = YES;
                *stop = YES;
            }
        }];
        
        if (result) {
            return result;
        }
        
        tVc = navVc.topViewController;
    }
    
    while (tVc.presentedViewController) {
        tVc = tVc.presentedViewController;
        if ([tVc isKindOfClass:controller]) {
            result = YES;
            break;
        }
        
        if ([tVc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVc = (UINavigationController *)tVc;
            [navVc.viewControllers enumerateObjectsUsingBlock:^(
                                                                __kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                                    if ([obj isKindOfClass:controller]) {
                                                                        result = YES;
                                                                        *stop = YES;
                                                                    }
                                                                }];
            
            if (result) {
                return result;
            }
            
            tVc = navVc.topViewController;
        }
    }
    
    return result;
}

@end
