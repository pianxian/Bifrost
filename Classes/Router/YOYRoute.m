//
//  YOYRoute.m
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import "YOYRoute.h"

@implementation YOYRoute

- (instancetype)initWithURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _destURL = url;
        
        NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
        
        NSString *parametersString = [url query];
        if (parametersString && parametersString.length > 0) {
            
            NSString *URLString = _destURL.absoluteString ?: @"";
            NSURLComponents *URLComponents = [[NSURLComponents alloc] initWithString:URLString];
            for (NSURLQueryItem *item in URLComponents.queryItems) {
                NSString *name = item.name;
                NSString *value = item.value;
                if (name && value) {
                    [mDict setObject:value forKey:name];
                }
            }
        }
        
        self.parameters = mDict;
        
    }
    return self;
}

- (void)setParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:_parameters];
    [mDict addEntriesFromDictionary:parameters];
    if (self.destURL) {
        [mDict setValue:self.destURL forKey:YOYRouterDestURLKey];
    }
    _parameters = [mDict copy];
}

/**
 *  TODO: 回调URL的逻辑
 */


- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n<%@ %p\n"
            @"\t URL: \"%@\"\n"
            @"\t routeParameters: \"%@\"\n"
            @"\t callbackURL: \"%@\"\n"
            @">",
            NSStringFromClass([self class]),
            self,
            [self.destURL description],
            self.parameters,
            [self.callbackURL description]];
}


#pragma mark - Parameter Retrieval via Object Subscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    id value    = self.parameters[key];
    return value;
}


#pragma mark - Equality

- (BOOL)isEqual:(YOYRoute *)object {
    
    if (self == object) {
        return YES;
    }
    else if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return (!self.destURL && !object.destURL) || [self.destURL isEqual:object.destURL];
}

- (NSUInteger)hash {
    return [self.destURL hash];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithURL:self.destURL];
}


@end
