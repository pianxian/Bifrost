//
//  PXServiceManagerProtocol.h
//  PXBifrost
//
//  Created by 胡伟伟 on 2023/7/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PXServiceManagerProtocol <NSObject>
@required
// service 完成注册
- (void)serviceDidRegisteredForProtocol:(Protocol *_Nullable)protocol;
@end

NS_ASSUME_NONNULL_END
