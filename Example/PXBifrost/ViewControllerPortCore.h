//
//  ViewControllerPortCore.h
//  PXBifrost_Example
//
//  Created by 胡伟伟 on 2023/7/13.
//  Copyright © 2023 huweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IViewControllerPort.h"

NS_ASSUME_NONNULL_BEGIN
@import PXBifrost;

@interface ViewControllerPortCore : NSObject<PXCoreProtocol, IViewControllerPort>

@end

NS_ASSUME_NONNULL_END
