//
//  MiKiURIRegisterManager.h
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXURIRegisterManager : NSObject
@property(class) BOOL inited;

/**
 自动注册URI命令
 */
+ (void)registerURINavisAuto;

@end
