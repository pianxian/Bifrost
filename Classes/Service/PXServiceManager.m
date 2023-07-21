//
//  MiKiServiceManager.m
//  Bifrost
//
//  Created by pianxian on 2021/10/11.
//  Copyright © 2023  All rights reserved.
//

#import "PXServiceManager.h"
#import <pthread/pthread.h>
#import <PXCommonServiceCenter.h>

#define LOCK() pthread_mutex_lock(&_lock);

#define UNLOCK() pthread_mutex_unlock(&_lock);

@interface PXServiceManager()

@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic, strong) NSMapTable <NSString *, id> *servicesMap;
@property (nonatomic, strong) NSMapTable <NSString *, NSMutableArray <PXCommonServiceClient *> *> *listenersMap;

@end

@implementation PXServiceManager

+ (PXServiceManager *)sharedManger
{
    static PXServiceManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _servicesMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory];
    _listenersMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory];
    
    return self;
}

- (void)registerService:(id)service forProtocol:(Protocol *)protocol
{
    NSString *protocolName = NSStringFromProtocol(protocol);
    LOCK();
    
    [self.servicesMap setObject:service forKey:protocolName];
    __auto_type callbackArray = [self removeListenersWithProtocol:protocol];
    [self callbackWithPXCommonServiceClients:callbackArray protocol:protocol];
    
    UNLOCK();
}

- (void)unRegisterService:(id)service forProtocol:(Protocol *)protocol
{
    NSString *protocolName = protocol ? NSStringFromProtocol(protocol) : nil;
    
    if (!protocolName) {
        return;
    }
    
    LOCK();
    
    id obj = [self.servicesMap objectForKey:protocolName];
    if (obj == service) {
        [self.servicesMap removeObjectForKey:protocolName];
    }
    
    UNLOCK();
}

- (void)unRegisterServiceForProtocol:(Protocol *)protocol
{
    LOCK();
    
    [self.servicesMap removeObjectForKey:NSStringFromProtocol(protocol)];
    
    UNLOCK();
}

- (id)getServiceWithProtocol:(Protocol *)protocol
{
    NSString *protocolName = NSStringFromProtocol(protocol);
    LOCK();
    
    id obj = [self.servicesMap objectForKey:protocolName];
    
    UNLOCK();
    
    return obj;
}

- (void)addServiceListener:(id<PXServiceManagerProtocol>)listener forProtocol:(Protocol *)protocol
{
    if (!listener || !protocol) {
        return;
    }
    
    NSString *protocolName = NSStringFromProtocol(protocol);
    
    if (!protocolName) {
        return;
    }
    
    LOCK();
    NSMutableArray <PXCommonServiceClient * > *listeners = [self.listenersMap objectForKey:protocolName];
    if (!listeners) {
        listeners = @[].mutableCopy;
        [self.listenersMap setObject:listeners forKey:protocolName];
    }
    PXCommonServiceClient *client = [[PXCommonServiceClient alloc] initWithObject:listener];
    [listeners addObject:client];
    UNLOCK();
}

- (NSArray <PXCommonServiceClient *> *)removeListenersWithProtocol:(Protocol *)protocol
{
    NSString *protocolName = NSStringFromProtocol(protocol);
    __auto_type listeners = [self.listenersMap objectForKey:protocolName];
    
    NSMutableArray <PXCommonServiceClient *> *removeObjectsArray = @[].mutableCopy;
    [listeners enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PXCommonServiceClient * _Nonnull obj,
                                                                             NSUInteger idx,
                                                                             BOOL * _Nonnull stop) {
        if (!obj.object) {
            [removeObjectsArray addObject:obj];
        }
    }];
    [listeners removeObjectsInArray:removeObjectsArray];
    
    if (listeners && 0 == listeners.count) {
        [self.listenersMap removeObjectForKey:protocolName];
    }
    
    return listeners.copy;
}

- (void)callbackWithPXCommonServiceClients:(NSArray <PXCommonServiceClient *> *)callbackArray protocol:(Protocol *)protocol
{
    [callbackArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PXCommonServiceClient * _Nonnull obj,
                                                                                 NSUInteger idx,
                                                                                 BOOL * _Nonnull stop) {
        id objecjt = obj.object;
        if ([objecjt respondsToSelector:@selector(serviceDidRegisteredForProtocol:)]) {
            [objecjt serviceDidRegisteredForProtocol:protocol];
        }
    }];
}

- (void)listenersPerformSelector:(SEL)sel protocol:(Protocol *)protocol
{
    NSString *protocolName = NSStringFromProtocol(protocol);
    LOCK();
    __auto_type listeners = [self.listenersMap objectForKey:protocolName];
    
    [listeners enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PXCommonServiceClient * _Nonnull obj,
                                                                             NSUInteger idx,
                                                                             BOOL * _Nonnull stop) {
        id objecjt = obj.object;
        if ([objecjt respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [objecjt performSelector:sel withObject:protocol];
#pragma clang diagnostic pop
        }
    }];
    
    UNLOCK();
}

@end
