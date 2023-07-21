//
//  MiKiSectionDataMapper.h
//  Mediator
//
//  Created by pianxian on 2022/2/22.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PXSectionDataMapper : NSObject

+ (instancetype)sharedInstance;

- (nullable Class)mappedClassForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
