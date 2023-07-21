//
//  MiKiService.m
//  Bifrost
//
//  Created by pianxian on 2023/2/22.
//  Copyright © 2023  All rights reserved.
//

#import "PXCoreService.h"
#import "PXServiceManager.h"

@implementation PXCoreService

+ (void)registerService:(id)service forProtocol:(Protocol *)protocol
{
    [PXServiceManager.sharedManger registerService:service forProtocol:protocol];
}

+ (void)unRegisterService:(id)service forProtocol:(Protocol *)protocol
{
    [PXServiceManager.sharedManger unRegisterService:service forProtocol:protocol];
}

+ (void)unRegisterServiceForProtocol:(Protocol *)protocol
{
    [PXServiceManager.sharedManger unRegisterServiceForProtocol:protocol];
}

+ (id)getServiceWithProtocol:(Protocol *)protocol
{
    return [PXServiceManager.sharedManger getServiceWithProtocol:protocol];
}

+ (id)getServiceWithProtocolName:(NSString *)protocolName
{
    Protocol *p = NSProtocolFromString(protocolName);
    return [PXServiceManager.sharedManger getServiceWithProtocol:p];
}

+ (void)addServiceListener:(id<PXServiceManagerProtocol>)listener forProtocol:(Protocol *)protocol
{
    [PXServiceManager.sharedManger addServiceListener:listener forProtocol:protocol];
}

+ (void)listenersPerformSelector:(SEL)sel protocol:(Protocol *)protocol
{
    [PXServiceManager.sharedManger listenersPerformSelector:sel protocol:protocol];
}


@end
