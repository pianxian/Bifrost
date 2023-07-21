//
//  MiKiCoreIMapper.h
//  Mediator
//
//  Created by pianxian on 2023/2/22.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PXCoreIMapper : NSObject

+ (instancetype)sharedObject;

- (Class)mappedClassForProtocol:(Protocol *)protocol;

- (Class)miki_matchProtocolWithClass:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
