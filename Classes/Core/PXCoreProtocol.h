//
//  PXCoreProtocol.h
//  PXBifrost
//
//  Created by 胡伟伟 on 2023/7/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define IMPLEMENT_COREPROTOCOL \
+ (instancetype)sharedCore{\
static dispatch_once_t onceToken;\
static id _sharedCore = nil;\
dispatch_once(&onceToken, ^{\
_sharedCore = [[self alloc] init];\
});\
return _sharedCore;\
}\

#define IMPLEMENT_INIT_COREPROTOCOL \
+ (instancetype)shareCoreInit {\
    id sharedCore = [[self alloc] init];\
    return sharedCore;\
}\

@protocol PXCoreProtocol <NSObject>
@required
+ (instancetype)sharedCore;

@end

/// 遵循该协议，MiKiCoreFactory 相关方法获取不到对应 Class 时不会进入断言
@protocol PXEnableNilCoreProtocol <NSObject>

@end
NS_ASSUME_NONNULL_END
