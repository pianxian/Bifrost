//
//  MiKiCoreFactory.m
//  Mediator
//
//  Created by pianxian on 2023/2/22.
//  Copyright © 2023  All rights reserved.
//

#import "PXCoreFactory.h"
#import "PXCoreIMapper.h"
#import "PXSectionDataMapper.h"
#import "PXCoreProtocol.h"
#import <objc/runtime.h>


static NSMapTable * protocolClassMap(void)
{
    static NSMapTable *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    });
    return table;
}


static NSMapTable * protocolGeneratorMap(void)
{
    static NSMapTable *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    });
    return table;
}

static BOOL _enableAssert = YES;

@implementation PXCoreFactory

+ (BOOL)enableAssert
{
    return _enableAssert;
}

+ (void)setEnableAssert:(BOOL)enableAssert
{
    _enableAssert = enableAssert;
}

#pragma mark - utls

+ (Class)classForProtocol:(Protocol *)protocol
{
    @synchronized (protocolClassMap()) {
        return ([protocolClassMap() objectForKey:NSStringFromProtocol(protocol)]
                ?: [PXSectionDataMapper.sharedInstance mappedClassForProtocol:protocol]);
    }
}

+ (BOOL)hasRegisteredFromClassMap:(Protocol *)protocol
{
    @synchronized (protocolClassMap()) {
        return [protocolClassMap() objectForKey:NSStringFromProtocol(protocol)] != nil;
    }
}

+ (BOOL)hasRegisteredFromGeneratorMap:(Protocol *)protocol
{
    @synchronized (protocolGeneratorMap()) {
        return [protocolGeneratorMap() objectForKey:NSStringFromProtocol(protocol)] != nil;
    }
}

#pragma mark - 注册

/// 保存 class 到 内存 Map 中，key 为 Protocol ，class 为 value
/// @param cls 对应的 Class
/// @param protocol 对应的 Map
+ (void)registerClass:(Class)cls forProtocol:(Protocol *)protocol
{
    @synchronized (protocolClassMap()) {
        Class currentClass = [protocolClassMap() objectForKey:NSStringFromProtocol(protocol)];
        if (currentClass != nil) {
            if (currentClass != cls) {
                [self assertOrLog:NO message:@"MiKiCoreFactory Protocol [%@] 协议已经注册，现有的 Class : %@, 新注册的 Class ：%@", NSStringFromProtocol(protocol), NSStringFromClass(currentClass), NSStringFromClass(cls)];
            }
            return;
        }
        [protocolClassMap() setObject:cls forKey:NSStringFromProtocol(protocol)];
    }
}

+ (void)registerGenerator:(PXCoreProtocolGeneratorBlock)generator forProtocol:(Protocol *)protocol
{
    @synchronized (protocolGeneratorMap()) {
        [protocolGeneratorMap() setObject:[generator copy] forKey:NSStringFromProtocol(protocol)];
    }
}

#pragma mark - 获取
/// 从内存 Map 中获取
/// @param protocol 对应的 protocol
+ (Class)classFromMapWithProtocol:(Protocol *)protocol
{
    Class cls = nil;
    @synchronized (protocolClassMap()) {
        cls = [protocolClassMap() objectForKey:NSStringFromProtocol(protocol)];
    }
    return cls;
}

/// 从 Section Data 段中获取
/// @param protocol 对应的 protocol
+ (Class)classFromSectionDataWithProtocol:(Protocol *)protocol
{
    return [PXSectionDataMapper.sharedInstance mappedClassForProtocol:protocol];
}

/// 字符串匹配
/// @param protocol 对应的 protocol
+ (Class)classFromStringMatchingWithProtocol:(Protocol *)protocol
{
    return [[PXCoreIMapper sharedObject] miki_matchProtocolWithClass:protocol];
}

+ (id)getCoreFromClass:(Class)cls
{
    id core = nil;
    if ([cls respondsToSelector:@selector(sharedCore)]) {
        core = [cls performSelector:@selector(sharedCore)];
    }
    return core;
}

+ (id)getAllocCoreFromClass:(Class)cls
{
    id core = nil;
    if ([cls respondsToSelector:@selector(new)]) {
        core = [cls performSelector:NSSelectorFromString(@"new")];
    }
    return core;
}

+ (id _Nullable)getCoreFromProtocol:(Protocol *)protocol
{
    PXCoreProtocolGeneratorBlock generator = [protocolGeneratorMap() objectForKey:NSStringFromProtocol(protocol)];
    if (generator) {
        return generator(protocol);
    }
    
    Class cls = [self getMappedClassFromProtocol:protocol];
    
    if (!cls) {
        return nil;
    }
    
    return [self getCoreFromClass:cls];
}


#pragma mark - 自注册获取

+ (id _Nullable)getMappedCoreFromProtocol:(Protocol *)protocol
{
    Class class = [self getMappedClassFromProtocol:protocol];
    id sharedCore = [self getCoreFromClass:class];
    if (!sharedCore && !protocol_conformsToProtocol(protocol, @protocol(PXEnableNilCoreProtocol))) {
        [self assertOrLog:(sharedCore != nil)
                  message:@"MiKiCoreFactory getMappedCoreFromProtocol:[%@] returns nil, plz check if you've registered your protocol.", NSStringFromProtocol(protocol)];
    }
    return sharedCore;
}

+ (id _Nullable)getAllocCoreFromProtocol:(Protocol *)protocol
{
    Class class = [self getMappedClassFromProtocol:protocol];
    id core = [self getAllocCoreFromClass:class];
    if (!core && !protocol_conformsToProtocol(protocol, @protocol(PXEnableNilCoreProtocol))) {
        [self assertOrLog:(core != nil)
                  message:@"MiKiCoreFactory getMappedCoreFromProtocol:[%@] returns nil, plz check if you've registered your protocol.", NSStringFromProtocol(protocol)];
    }
    return core;
}

/// 根据协议获取 Class ，优先级如下：
/// 1. 检查内存 Map 是否有对应的 Class
/// 2. 检查 Section Data 段是否有对应的 Class
/// 3. 检查是否有满足字符串匹配的 Class
/// @param protocol 对应的 Protocol
+ (Class _Nullable)getMappedClassFromProtocol:(Protocol *)protocol
{
    Class class = nil;
    class = [self classFromMapWithProtocol:protocol];
    
    if (!class) {
        class = [self classFromSectionDataWithProtocol:protocol];
        [self registerClass:class forProtocol:protocol];
    }
    
    if (!class) {
        class = [self classFromStringMatchingWithProtocol:protocol];
        [self registerClass:class forProtocol:protocol];
    }
    
    if (!class && !protocol_conformsToProtocol(protocol, @protocol(PXEnableNilCoreProtocol))) {
        [self assertOrLog:NO message:@"MiKiCoreFactory getMappedClassFromProtocol:[%@] returns nil, plz check if you've registered your protocol.", NSStringFromProtocol(protocol)];
    }
    
    return class;
}

+ (void)assertOrLog:(BOOL)condition message:(NSString *)format,... NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    NSString *desc = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    if (_enableAssert) {
        NSAssert(condition, @"%@", desc);
    } else {
        NSLog(@"%@", desc);
    }
}
@end
