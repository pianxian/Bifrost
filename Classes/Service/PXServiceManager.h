//
//  MiKiServiceManager.h
//  Bifrost
//
//  Created by pianxian on 2021/10/11.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXServiceManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXServiceManager : NSObject

@property (nonatomic, class, strong, readonly) PXServiceManager *sharedManger;
///  注册服务，如果有同样的服务已经注册，会将旧服务干掉
/// @param service 服务
/// @param protocol 服务协议
- (void)registerService:(nullable id)service forProtocol:(Protocol *)protocol;
/// 注销服务
/// @param service 服务
/// @param protocol 服务协议
- (void)unRegisterService:(id)service forProtocol:(Protocol *)protocol;
///获取注册的服务
/// @param protocol 协议
- (nullable id)getServiceWithProtocol:(Protocol *)protocol;
/// 通过协议取消注册
/// @param protocol 协议
- (void)unRegisterServiceForProtocol:(Protocol *)protocol;
/// 监听某个 object 注册和取消注册的通知，以让使用方在bridge可用/不可用的时候进行相应的操作
/// @param listener 需要监听生命周期的对象, weak 持有 listener
/// @param protocol 协议
- (void)addServiceListener:(id<PXServiceManagerProtocol>)listener forProtocol:(Protocol *)protocol;
/// 兼容使用
/// @param sel callback sel
/// @param protocol 协议名
- (void)listenersPerformSelector:(SEL)sel protocol:(Protocol *)protocol;
@end

NS_ASSUME_NONNULL_END
