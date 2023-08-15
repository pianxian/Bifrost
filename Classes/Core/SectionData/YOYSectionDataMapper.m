//
//  MiKiSectionDataMapper.m
//  Mediator
//
//  Created by pianxian on 2023/2/22.
//  Copyright © 2023  All rights reserved.
//

#import "YOYSectionDataMapper.h"
#import "YOYSectionDataLookup.h"
#import "YOYCoreSectionDataMacros.h"

@interface YOYSectionDataMapper()

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *dictionary;

@property (nonatomic, assign, getter = isLoad) BOOL load;

@end

@implementation YOYSectionDataMapper

- (instancetype)init
{
    self = [super init];
    if (!self) { return nil; }
    _dictionary = @{}.mutableCopy;
    return self;
}

+ (instancetype)sharedInstance
{
    static YOYSectionDataMapper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (Class)mappedClassForProtocol:(Protocol *)protocol
{
    NSString *protocolName = NSStringFromProtocol(protocol);
    if (protocolName.length <= 0) {
        return Nil;
    }
    NSString *className = nil;
    
    @synchronized (self.dictionary) {
        
        [self loadSectionDataIfNeed];
        
        className = self.dictionary[protocolName];
    }
    
    return className.length > 0 ? NSClassFromString(className) : Nil;
}

- (void)loadSectionDataIfNeed
{
    if (!self.isLoad) {
        [YOYSectionDataLookup readSectionName:YOY_CORE_SECTION_NAME
                              imageProcessStep:sizeof(char *)
                                    usingBlock:^(const void * _Nullable address) {
            if (NULL == address) {
                return;
            }
            char *strs = *(char **)address;
            NSString *string = [NSString stringWithUTF8String:strs];
            NSArray *tuple = [string componentsSeparatedByString:@"#"];
            if (2 == tuple.count) {
                NSString *protocolName = tuple.firstObject;
                NSString *className = tuple.lastObject;
                self.dictionary[protocolName] = className;
            }
        }];
        self.load = YES;
    }
}


@end
