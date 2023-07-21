//
//  PXRouteMatcher.h
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXRoute.h"

@interface PXRouteMatcher : NSObject
@property (nonatomic, readonly) NSString  *route;

+ (instancetype)matcherWithPath:(NSString *)path;

- (BOOL)matchRoute:(PXRoute *)route;

@end
