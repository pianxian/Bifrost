//
//  MiKiService.m
//  Bifrost
//
//  Created by pianxian on 2023/2/22.
//  Copyright © 2023  All rights reserved.
//

#import "YOYCoreService.h"
#import "YOYServiceManager.h"

@implementation YOYCoreService

+ (void)registerService:(id)service forProtocol:(Protocol *)protocol
{
    [YOYServiceManager.sharedManger registerService:service forProtocol:protocol];
}

+ (void)unRegisterService:(id)service forProtocol:(Protocol *)protocol
{
    [YOYServiceManager.sharedManger unRegisterService:service forProtocol:protocol];
}

+ (void)unRegisterServiceForProtocol:(Protocol *)protocol
{
    [YOYServiceManager.sharedManger unRegisterServiceForProtocol:protocol];
}

+ (id)getServiceWithProtocol:(Protocol *)protocol
{
    return [YOYServiceManager.sharedManger getServiceWithProtocol:protocol];
}

+ (id)getServiceWithProtocolName:(NSString *)protocolName
{
    Protocol *p = NSProtocolFromString(protocolName);
    return [YOYServiceManager.sharedManger getServiceWithProtocol:p];
}

+ (void)addServiceListener:(id<YOYServiceManagerProtocol>)listener forProtocol:(Protocol *)protocol
{
    [YOYServiceManager.sharedManger addServiceListener:listener forProtocol:protocol];
}

+ (void)listenersPerformSelector:(SEL)sel protocol:(Protocol *)protocol
{
    [YOYServiceManager.sharedManger listenersPerformSelector:sel protocol:protocol];
}


@end
