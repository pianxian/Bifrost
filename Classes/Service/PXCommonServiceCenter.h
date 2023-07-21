//
//  PXCommonServiceCenter.h
//  Bifrost
//
//  Created by pianxian on 2021/11/13.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>

#define AddCoreClient(protocolName, client) ([[PXCommonServiceCenter defaultCenter] addServiceClient:client withKey:@protocol(protocolName)])

#define RemoveCoreClient(protocolName, client) ([[PXCommonServiceCenter defaultCenter] removeServiceClient:client withKey:@protocol(protocolName)])

#define RemoveCoreClientAll(client) ([[PXCommonServiceCenter defaultCenter] removeServiceClient:client])

#define NotifyCoreClient(protocolName, selector, func) NOTIFY_SERVICE_CLIENT(protocolName, selector, func)


typedef Protocol *CommonServiceClientKey;

NS_ASSUME_NONNULL_BEGIN

@interface PXCommonServiceCenter : NSObject

+ (PXCommonServiceCenter *)defaultCenter;

// 获取服务对象。
// 如果对象不存在， 会自动创建。
- (id)getService:(Class) cls;

- (void)removeService:(Class) cls;

- (void)setNotifyingClientsWithKey:(CommonServiceClientKey)key isNotifying:(BOOL)isNotifying;
- (void)setNotifyingClientsWithProtocolName:(NSString *)protocolName isNotifying:(BOOL)isNotifying;
- (BOOL)isNotifyingClientsWithKey:(CommonServiceClientKey)key;
- (NSArray *)serviceClientsWithKey:(CommonServiceClientKey)key;
- (NSArray *)serviceClientsWitProtocolName:(NSString *)protocolName;
- (void)addServiceClient:(id)client withKey:(CommonServiceClientKey)key;
- (void)addServiceClient:(id)client withProtocolName:(NSString *)protocolName;
- (void)removeServiceClient:(id)client withKey:(CommonServiceClientKey)key;
- (void)removeServiceClient:(id)client;

@end

#define GET_SERVICE(obj) (obj *)[[PXCommonServiceCenter defaultCenter] getService:[obj class]]

#define REMOVE_SERVICE(obj) [[PXCommonServiceCenter defaultCenter] removeService:[obj class]]

/// 为了client不被增加引用计数，引入一个包装类。
@interface PXCommonServiceClient : NSObject

@property (nonatomic, weak) id object;
- (id)initWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END

#define ADD_SERVICE_CLIENT(protocolName, object) [[PXCommonServiceCenter defaultCenter] addServiceClient:object withKey:@protocol(protocolName)]
#define REMOVE_SERVICE_CLIENT(protocolName, object) [[PXCommonServiceCenter defaultCenter] removeServiceClient:object withKey:@protocol(protocolName)]
#define REMOVE_ALL_SERVICE_CLIENT(object) [[PXCommonServiceCenter defaultCenter] removeServiceClient:object]
#define NOTIFY_SERVICE_CLIENT(protocolName, selector, func) \
{ \
[[PXCommonServiceCenter defaultCenter] setNotifyingClientsWithKey:@protocol(protocolName) isNotifying:YES]; \
NSArray *__clients__ = [[PXCommonServiceCenter defaultCenter] serviceClientsWithKey:@protocol(protocolName)]; \
for (PXCommonServiceClient *client in __clients__) \
{ \
    id obj = client.object; \
    if ([obj respondsToSelector:selector]) \
    { \
        [obj func]; \
    } \
} \
[[PXCommonServiceCenter defaultCenter] setNotifyingClientsWithKey:@protocol(protocolName) isNotifying:NO]; \
}
