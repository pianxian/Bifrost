//
//  INavigationController.h
//  PXBifrost_Example
//
//  Created by 胡伟伟 on 2023/7/13.
//  Copyright © 2023 huweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol INavigationController <NSObject>
+ (instancetype)alloc;

- (UINavigationController *)initWithRootViewController:(UIViewController *)rootViewController;
@end

NS_ASSUME_NONNULL_END
