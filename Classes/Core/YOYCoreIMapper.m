//
//  MiKiCoreIMapper.m
//  Mediator
//
//  Created by pianxian on 2023/2/22.
//  Copyright © 2023  All rights reserved.
//

#import "YOYCoreIMapper.h"
#import "YOYSectionDataMapper.h"

@implementation YOYCoreIMapper

+ (instancetype)sharedObject
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (Class)mappedClassForProtocol:(Protocol *)protocol
{
    Class cls = [YOYSectionDataMapper.sharedInstance mappedClassForProtocol:protocol];
    if (!cls) {
        NSAssert(NO, @"PX_CORE_REGISTER not register, Check %@", NSStringFromProtocol(protocol));
    }
    return cls;
}

- (Class )miki_matchProtocolWithClass:(Protocol *)protocol
{
    NSString *protoStr = NSStringFromProtocol(protocol);
    // 对应匹配规则：Iclass————class
    NSString *classIStr = [protoStr substringFromIndex:1];
    Class classI = NSClassFromString(classIStr);
    NSString *myClassIStr = NSStringFromClass(classI);
    if(myClassIStr.length && [classI conformsToProtocol:protocol]) {
        return classI;
    }
    
    // 对应匹配规则：IMiKiclass————class
    NSString *classIMiKiStr = [protoStr substringFromIndex:3];
    Class IMiKiClass = NSClassFromString(classIMiKiStr);
    NSString *myClassIMiKiStr = NSStringFromClass(IMiKiClass);
    if(myClassIMiKiStr.length && [IMiKiClass conformsToProtocol:protocol]) {
        return IMiKiClass;
    }
    
    // 对应匹配规则：Iclass————classCore
    NSString *clsCoreStr =  [NSString stringWithFormat:@"%@Core",classIStr];
    Class clsCoreStrClass = NSClassFromString(clsCoreStr);
    NSString *clsCoreStrClassStr = NSStringFromClass(clsCoreStrClass);
    if(clsCoreStrClassStr.length && [clsCoreStrClass conformsToProtocol:protocol]) {
        return clsCoreStrClass;
    }

    // 对应匹配规则：Iclass———— MiKiclass
    NSString *mikiClassIStr = [NSString stringWithFormat:@"MiKi%@",classIStr];
    Class mikiClass = NSClassFromString(mikiClassIStr);
    NSString *mikiClassStr = NSStringFromClass(mikiClass);
    if(mikiClassStr.length && [mikiClass conformsToProtocol:protocol]) {
        return mikiClass;
    }

    // 对应匹配规则：IclassCore————class
    NSString *classCoreStr = [classIStr substringToIndex:classIStr.length - 4];
    Class classCoreI = NSClassFromString(classCoreStr);
    NSString *myClassCoreIStr = NSStringFromClass(classCoreI);
    if(myClassCoreIStr.length && [classCoreI conformsToProtocol:protocol]) {
        return classCoreI;
    }
    
    // 对应匹配规则：IclassQuery————class
    NSRange searchRange = NSMakeRange(1, protoStr.length - 6);
    NSString *classQueryStr = [protoStr substringWithRange:searchRange];
    Class queryClass = NSClassFromString(classQueryStr);
    NSString *queryClassIStr = NSStringFromClass(queryClass);
    if(queryClassIStr.length && [queryClass conformsToProtocol:protocol]) {
        return queryClass;
    }
    
    // 对应匹配规则：IclassQuery————classCore
    NSString *classQueryCoreStr =  [NSString stringWithFormat:@"%@Core",classQueryStr];
    Class queryCoreClass = NSClassFromString(classQueryCoreStr);
    NSString *queryCoreClassIStr = NSStringFromClass(queryCoreClass);
    if(queryCoreClassIStr.length && [queryCoreClass conformsToProtocol:protocol]) {
        return queryCoreClass;
    }
    
    return nil;
}


@end
