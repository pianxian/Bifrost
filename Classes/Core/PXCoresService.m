//
//  PXCoresService.m
//  Mediator
//
//  Created by pianxian on 2023/2/21.
//  Copyright © 2023  All rights reserved.
//

#import "PXCoresService.h"
#import "PXCoreFactory.h"

@implementation PXCoresService
#pragma mark - Protocl Class
//通过类获取对象
+ (id)registerCore:(Class )className
{
    return [PXCoreFactory getCoreFromClass:className];
}

+ (id)registerCoreFromClassName:(NSString *)className
{
    Class cls = NSClassFromString(className);
    return [PXCoreFactory getCoreFromClass:cls];
}

//通过协议获取对象
+ (id)registerCoreI:(Protocol *)protocolName
{
    return [PXCoreFactory getCoreFromProtocol:protocolName];
}

+ (id)registerMappedCore:(Protocol *)protocolName
{
    return [PXCoreFactory getAllocCoreFromProtocol:protocolName];
}

//通过协议映射对象
+ (id)registerMappedCoreI:(Protocol *)protocolName
{
    return [PXCoreFactory getMappedCoreFromProtocol:protocolName];
}

//通过协议映射类方法
+ (Class)registerMappedClassI:(Protocol *)protocolName
{
    return [PXCoreFactory getMappedClassFromProtocol:protocolName];
}

+ (id)registerCoreIFromString:(NSString *)protocolName
{
    return [PXCoreFactory getCoreFromProtocol:NSProtocolFromString(protocolName)];
}

+ (Class)registerMappedClassIFromString:(NSString *)protocolName
{
    return [self registerMappedClassI:NSProtocolFromString(protocolName)];
}

@end
