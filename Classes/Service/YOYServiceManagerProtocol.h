//
//  YOYServiceManagerProtocol.h
//  Bifrost
//
//  Created by 胡伟伟 on 2023/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YOYServiceManagerProtocol <NSObject>
@required
// service 完成注册
- (void)serviceDidRegisteredForProtocol:(Protocol *_Nullable)protocol;
@end

NS_ASSUME_NONNULL_END
