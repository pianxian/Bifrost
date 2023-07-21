//
//  PXCommonServiceCenter.m
//  Bifrost
//
//  Created by pianxian on 2021/11/13.
//  Copyright © 2023  All rights reserved.
//

#import "PXCommonServiceCenter.h"
#import <objc/runtime.h>


static PXCommonServiceCenter *_serviceCenter = nil;

@interface PXCommonServiceCenter () {
    NSMutableDictionary *_serviceDictionary;
    NSMutableDictionary *_clientDictionary;
    //用于纪录当前正在遍历中的service
    NSMutableDictionary *_notifyingKeys;
}

@end

@implementation PXCommonServiceCenter

- (id)init
{
    if (self = [super init]) {
        [self log:@"Create service center"];
        _serviceDictionary = [[NSMutableDictionary alloc] init];
        _clientDictionary = [[NSMutableDictionary alloc] init];
        _notifyingKeys = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (_serviceDictionary != nil) {
        [self log:@"dealloc service center"];
        @synchronized(self) {
            [_serviceDictionary removeAllObjects];
        }
    }

    _serviceCenter = nil;
}

+ (PXCommonServiceCenter *)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceCenter = [[PXCommonServiceCenter alloc] init];
    });
    return _serviceCenter;
}

- (id)getService:(Class)cls
{
    NSString *key = [NSString stringWithUTF8String:class_getName(cls)];
    
    id obj = nil;
    @synchronized(self) {
        obj = [_serviceDictionary objectForKey:key];
        if (obj == nil) {
            // 将init放在alloc之后， 防止在init里面做了啥有影响的东西。
            obj = [[cls alloc] init];
            [_serviceDictionary setObject:obj forKey:key];
            [self log:@"Create service object: %@", obj];
        }
    }
    
    return obj;
}

- (void)removeService:(Class) cls
{
    NSString *key = [NSString stringWithUTF8String:class_getName(cls)];
    if (!key) {
        [self log:@"removeService key is nil!"];
        return;
    }
    
    @synchronized(self) {
        [self log:@"Remove service object %@", key];
        [_serviceDictionary removeObjectForKey:key];
    }
}

- (NSMutableArray *)_getClientsWithKey:(CommonServiceClientKey)key
{
    if ([NSThread mainThread] != [NSThread currentThread]) {
        [self log:@"get client protocol for key %@ in the other thread",NSStringFromProtocol(key)];
    }

    NSString *strKey = NSStringFromProtocol(key);
    NSMutableArray *clients = nil;
    @synchronized(self) {
        clients = [_clientDictionary objectForKey:strKey];
        if (!clients && strKey) {
            clients = [[NSMutableArray alloc] init];
            [_clientDictionary setObject:clients forKey:strKey];
        }
    }
    return clients;
}

- (NSArray *)serviceClientsWithKey:(CommonServiceClientKey)key
{
    NSArray *clients = @[];
    @synchronized(self) {
        NSMutableArray *result = [self _getClientsWithKey:key];
        clients = [result copy];
    }
    return clients;
}

- (NSArray *)serviceClientsWitProtocolName:(NSString *)protocolName
{
    CommonServiceClientKey key = NSProtocolFromString(protocolName);
    return [self serviceClientsWithKey:key];
}

- (void)addServiceClient:(id)client withKey:(CommonServiceClientKey)key
{
    if ([NSThread mainThread] != [NSThread currentThread]) {
        [self log:@"add service client protocol for %p for key %@ in the other thread", client,NSStringFromProtocol(key)];
    }
    
    if (client) {
        if (![client conformsToProtocol:key]) {
            [self log:@"client doesnot conforms to protocol: %@", NSStringFromProtocol(key)];
        }
        
        @synchronized(self) {
            NSMutableArray *clients = [self _getClientsWithKey:key];
            NSArray *staticClients = [clients copy];
            for (PXCommonServiceClient *obj in staticClients) {
                if (obj.object == client) {
                    return;
                }
            }
            [clients addObject:[[PXCommonServiceClient alloc] initWithObject:client]];
        }
        [self log:@"add client %@ for protocol %@", client, NSStringFromProtocol(key)];
    }
}

- (void)addServiceClient:(id)client withProtocolName:(NSString *)protocolName
{
    Protocol *p = NSProtocolFromString(protocolName);
    [self addServiceClient:client withKey:p];
}

- (void)removeServiceClient:(id)client withKey:(CommonServiceClientKey)key
{
    if ([NSThread mainThread] != [NSThread currentThread]) {
        [self log:@"remove service client protocol for %p for key %@ in the other thread", client,NSStringFromProtocol(key)];
    }
    
    if (client) {
        @synchronized(self) {
            NSMutableArray *clients = [self _getClientsWithKey:key];
            PXCommonServiceClient *found = nil;
            for (PXCommonServiceClient *clientObj in clients) {
                if (clientObj.object == client) {
                    found = clientObj;
                    break;
                }
            }
            if (found) {
                [self log:@"remove client %p for protocol %@", client, NSStringFromProtocol(key)];
                found.object = nil;
                [clients removeObject:found];
            }
            
            //检查为空的，因为dealloc的时候weak已经被置空
            NSArray *temp = [NSArray arrayWithArray:clients];
            for (PXCommonServiceClient *clientObj in temp) {
                if (clientObj && clientObj.object == nil) {
                    [clients removeObject:clientObj];
                }
            }
        }
    }
}

- (void)removeServiceClient:(id)client
{
    if ([NSThread mainThread] != [NSThread currentThread]) {
        [self log:@"remove service client protocol for %p in the other thread", client];
    }
    NSLog(@"remove all client protocol for %p", client);
    if (client) {
        @synchronized(self) {
            //使用[_clientDictionary allValues] 遍历会极小概率出来因allvalues中会出现nil而导致的nsplaceholderarray initwithobjects:count: attempt to insert nil object from objects[num]崩溃
            [_clientDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSMutableArray class]]) {
                    return;
                }
                NSMutableArray *clients = obj;
                PXCommonServiceClient *found = nil;
                for (PXCommonServiceClient *clientObj in clients.copy) {
                    if (clientObj.object == client) {
                        found = clientObj;
                        break;
                    }
                }
                if (found) {
                    found.object = nil;
                    [clients removeObject:found];
                }
                
                //检查为空的，因为dealloc的时候weak已经被置空(你好，黑科技)
                NSArray *temp = [NSArray arrayWithArray:clients];
                for (PXCommonServiceClient *clientObj in temp) {
                    if (clientObj && clientObj.object == nil) {
                        [clients removeObject:clientObj];
                    }
                }
            }];
        }
    }
}

- (void)setNotifyingClientsWithKey:(CommonServiceClientKey)key isNotifying:(BOOL)isNotifying
{
    NSString *strKey = NSStringFromProtocol(key);
    [self setNotifyingClientsWithProtocolName:strKey isNotifying:isNotifying];
}

- (void)setNotifyingClientsWithProtocolName:(NSString *)protocolName isNotifying:(BOOL)isNotifying
{
    if (protocolName.length == 0) {
        NSAssert(false, @"setNotifyingClientsWithKey:strKey should not be nil!");
        return;
    }
    
    @synchronized(self) {
        if (isNotifying) {
            [_notifyingKeys setObject:protocolName forKey:protocolName];
        } else {
            [_notifyingKeys removeObjectForKey:protocolName];
        }
    }
}

- (BOOL)isNotifyingClientsWithKey:(CommonServiceClientKey)key
{
    NSString *strKey = NSStringFromProtocol(key);
    if (strKey.length == 0) {
        NSAssert(false, @"isNotifyingClientsWithKey:strKey should not be nil!");
        return NO;
    }
    
    BOOL result = NO;
    @synchronized (self) {
        result = ([_notifyingKeys objectForKey:strKey] != nil);
    }
    return result;
}

- (void)log:(NSString *)format,... NS_FORMAT_FUNCTION(1, 2)
{
    va_list args;
    va_start(args, format);
    NSString *desc = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"%@", desc);
}

@end

@implementation PXCommonServiceClient

- (id)initWithObject:(id)object
{
    if (self = [super init]) {
        self.object = object;
    }
    return self;
}
@end
