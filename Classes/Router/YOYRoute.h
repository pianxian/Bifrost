//
//  YOYRoute.h
//  Bifrost
//
//  Created by pianxian on 2020/2/28.
//  Copyright © 2023  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 当前Route实例的destURL
static NSString * const YOYRouterDestURLKey = @"YOYRouterDestURLKey";

@interface YOYRoute : NSObject <NSCopying>


- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic, copy, readonly) NSURL *destURL;

@property (nonatomic, copy) NSDictionary *parameters;

@property (nonatomic, strong) NSDictionary *info;

@property (nonatomic, strong) UIViewController *viewController;

/**
 *  回调地址
 */
@property (nonatomic, strong) NSURL *callbackURL;

- (id)objectForKeyedSubscript:(NSString *)key;

@end
