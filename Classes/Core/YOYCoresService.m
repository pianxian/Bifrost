//
//  YOYCoresService.m
//  Mediator
//
//  Created by pianxian on 2023/2/21.
//  Copyright © 2023  All rights reserved.
//

#import "YOYCoresService.h"
#import "YOYCoreFactory.h"

@implementation YOYCoresService
#pragma mark - Protocl Class
//通过类获取对象
+ (id)registerCore:(Class )className
{
    return [YOYCoreFactory getCoreFromClass:className];
}

+ (id)registerCoreFromClassName:(NSString *)className
{
    Class cls = NSClassFromString(className);
    return [YOYCoreFactory getCoreFromClass:cls];
}

//通过协议获取对象
+ (id)registerCoreI:(Protocol *)protocolName
{
    return [YOYCoreFactory getCoreFromProtocol:protocolName];
}

+ (id)registerMappedCore:(Protocol *)protocolName
{
    return [YOYCoreFactory getAllocCoreFromProtocol:protocolName];
}

//通过协议映射对象
+ (id)registerMappedCoreI:(Protocol *)protocolName
{
    return [YOYCoreFactory getMappedCoreFromProtocol:protocolName];
}

//通过协议映射类方法
+ (Class)registerMappedClassI:(Protocol *)protocolName
{
    return [YOYCoreFactory getMappedClassFromProtocol:protocolName];
}

+ (id)registerCoreIFromString:(NSString *)protocolName
{
    return [YOYCoreFactory getCoreFromProtocol:NSProtocolFromString(protocolName)];
}

+ (Class)registerMappedClassIFromString:(NSString *)protocolName
{
    return [self registerMappedClassI:NSProtocolFromString(protocolName)];
}

@end
