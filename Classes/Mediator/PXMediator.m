//
//  MiKiMediator.m
//  Mediator
//
//  Created by pianxian on 2023/1/13.
//  Copyright © 2023  All rights reserved.
//

#import "PXMediator.h"
#import <objc/runtime.h>

@implementation PXMediator

+ (instancetype)sharedInstance
{
    static PXMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[PXMediator alloc] init];
    });
    return mediator;
}

- (id __nullable)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion
{
    if (![url.scheme isEqualToString:@"aaa"]) {
        return @(NO);
    }

    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    id result = [self performTarget:url.host action:actionName params:nil];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}

// ******************** NOTE  ************************

// targetName 是 Target_XXX 类文件 的 XXX 部分
// actionName 是定义在 Target_XXX 类文件中的 select name 后半部分

// 此函数的作用：
//  传入 Target_XXX.h 文件中 xxx 的字符串； NSClassFromString 动态生成类
//  传入 Target_XXX.h 文件中 action selector 的函数名字符串； NSSelectorFromString 动态生成 函数

// ******************** NOTE  ************************


- (id __nullable)performTarget:(nullable NSString *)targetName action:(nullable NSString *)actionName params:(nullable id)params
{
    
    NSString *targetClassString = [NSString stringWithFormat:@"%@", targetName];
    Class targetClass = NSClassFromString(targetClassString);
    id target = [[targetClass alloc] init];
    
    NSString *actionString = [NSString stringWithFormat:@"%@", actionName];
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        return nil;
    }
    
    if (actionName != nil) {
        if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [target performSelector:action withObject:params];
        } else {
            SEL action = NSSelectorFromString(@"notFound:");
            if ([target respondsToSelector:action]) {
                return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
            } else {
                return nil;
            }
        }
    }
    return target;
}

- (id __nullable)performClass:(nullable NSString *)className action:(nullable NSString *)actionName params:(nullable id)params
{
    NSString *targetClassString = [NSString stringWithFormat:@"%@", className];
    Class targetClass = NSClassFromString(targetClassString);
    NSString *actionString = [NSString stringWithFormat:@"%@", actionName];
    SEL action = NSSelectorFromString(actionString);
    
    if (targetClass == nil) {
        return nil;
    }
    
    if ([targetClass respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [targetClass performSelector:action withObject:params];
        
    } else {
        SEL action = NSSelectorFromString(@"notFound:");
        if ([targetClass respondsToSelector:action]) {
            return [targetClass performSelector:action withObject:params];
#pragma clang diagnostic pop
        } else {
            return nil;
        }
    }
}

- (id __nullable)performSingleTarget:(nullable id)targetClass action:(nullable NSString *)actionName params:(nullable id)params onMainThread:(BOOL )ifNeed
{
    NSString *actionString = [NSString stringWithFormat:@"%@", actionName];
    SEL action = NSSelectorFromString(actionString);
    
    if (targetClass == nil) {
        return nil;
    }
    
    if ([targetClass respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (ifNeed) {
            [targetClass performSelectorOnMainThread:action withObject:params waitUntilDone:NO];
            return nil;
        }
        else {
            return [targetClass performSelector:action withObject:params];
        }
    } else {
        SEL action = NSSelectorFromString(@"notFound:");
        if ([targetClass respondsToSelector:action]) {
            return [targetClass performSelector:action withObject:params];
#pragma clang diagnostic pop
        } else {
            return nil;
        }
    }
}

- (id __nullable)performClass:(nullable id)targetClassName action:(nullable NSString *)actionName withObjects:(NSArray *)objects
{
    NSString *actionString = [NSString stringWithFormat:@"%@", actionName];
    SEL selector = NSSelectorFromString(actionString);
    // 方法签名(方法的描述)
    Class targetClass = NSClassFromString(targetClassName);
    NSMethodSignature *signature = [[targetClass class] methodSignatureForSelector:selector];

    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = [targetClass class];
    invocation.selector = selector;
    
//     设置参数
    NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    paramsCount = MIN(paramsCount, objects.count);
//    NSInteger paramsCount = objects.count;
    [self setInv:invocation andArgs:objects argsCount:paramsCount];
    
    // 调用方法
    [invocation invoke];
    // 获取返回值
    __unsafe_unretained id returnValue = nil;
    if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}

- (void)setInv:(NSInvocation *)inv andArgs:(NSArray *)args argsCount:(NSUInteger)count
{
    for (int i = 0; i<count; i++) {
        NSObject*obj = args[i];
//        处理参数是NULL类型的情况
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = nil;
        }
        //对整形数值等的处理
        if ([obj isKindOfClass:[NSNumber class]])      //对数值数据的处理
        {
            void *p;
            NSNumber *num = (NSNumber *)obj;
            if (strcmp([num objCType], @encode(float)) == 0)
            {
                float v = [num floatValue];
                p = &v;
            }
            else if (strcmp([num objCType], @encode(double)) == 0)
            {
                double v = [num doubleValue];
                p = &v;
            }
            else if (strcmp([num objCType], @encode(NSInteger)) == 0)
            {
                NSInteger v = [num integerValue];
                p = &v;
            }
            else
            {
                long v = [num longValue];
                p = &v;
            }
            [inv setArgument:p atIndex:i+2];
            continue;
        }
        [inv setArgument:&obj atIndex:i+2];
    }
}

- (id __nullable)performTargetClass:(nullable id)targetClass action:(nullable NSString *)actionName withObjects:(NSArray *)objects
{
    NSString *actionString = [NSString stringWithFormat:@"%@", actionName];
    SEL selector = NSSelectorFromString(actionString);
    // 方法签名(方法的描述)
    NSMethodSignature *signature = [[targetClass class] instanceMethodSignatureForSelector:selector];
    
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = targetClass;
    invocation.selector = selector;
    
    // 设置参数
    NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    paramsCount = MIN(paramsCount, objects.count);
//    NSInteger paramsCount = objects.count;
    [self setInv:invocation andArgs:objects argsCount:paramsCount];
    
    // 调用方法
    [invocation invoke];
    // 获取返回值
    __unsafe_unretained id returnValue = nil;
    if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}

@end
