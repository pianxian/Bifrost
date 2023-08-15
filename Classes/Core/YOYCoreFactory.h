//
//  PXCoreFactory.h
//  PXBifrost
//
//  Created by 胡伟伟 on 2023/7/21.
//

#import <Foundation/Foundation.h>
#import "YOYCoreProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YOYCoreFactory : NSObject

typedef id _Nonnull (^YOYCoreProtocolGeneratorBlock)(Protocol * protocol);

+ (void)registerClass:(Class<YOYCoreProtocol>)cls forProtocol:(Protocol *)protocol;
+ (void)registerGenerator:(YOYCoreProtocolGeneratorBlock)generator forProtocol:(Protocol *)protocol;

+ (Class)classForProtocol:(Protocol *)protocol;
+ (BOOL)hasRegisteredFromClassMap:(Protocol *)protocol;
+ (BOOL)hasRegisteredFromGeneratorMap:(Protocol *)protocol;

+ (id)getCoreFromClass:(Class)cls;

/// 获取 Protocol 对应的 Class sharedCore
/// 1. 判断是否有 Protocol 对应的 YOYCoreProtocolGeneratorBlock ，如果有，就使用 YOYCoreProtocolGeneratorBlock 来生成 对应的 core
/// 2. 调用 getMappedClassFromProtocol: 来获取对应的 Class ，调用该 Class 的 sharedCore
/// @param protocol 对应的 Protocol
+ (id _Nullable)getCoreFromProtocol:(Protocol *)protocol;

/// 获取 Protocol 对应的 Class sharedCore
/// 1. 判断是否有 Protocol 对应的 YOYCoreProtocolGeneratorBlock ，如果有，就使用 YOYCoreProtocolGeneratorBlock 来生成 对应的 core
/// 2. 调用 getMappedClassFromProtocol: 来获取对应的 Class ，调用该 Class 的 sharedCore
/// @param protocol 对应的 Protocol
+ (id _Nullable)getMappedCoreFromProtocol:(Protocol *)protocol;

///获取一个非单例实例对象
+ (id _Nullable)getAllocCoreFromProtocol:(Protocol *)protocol;

/// 根据协议获取 Class ，优先级如下：
/// 1. 检查内存 Map 是否有对应的 Class
/// 2. 检查 Section Data 段是否有对应的 Class
/// 3. 检查是否有满足字符串匹配的 Class
/// @param protocol 对应的 Protocol
+ (Class _Nullable)getMappedClassFromProtocol:(Protocol *)protocol;

@property (nonatomic, assign, class) BOOL enableAssert;

@end

NS_ASSUME_NONNULL_END
