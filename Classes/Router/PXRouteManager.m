//
//  PXRouteManager.m
//  Bifrost
//
//  Created by pianxian on 2020/2/28.
//  Copyright © 2023  All rights reserved.
//

#import "PXRouteManager.h"
#import "PXRouteMatcher.h"
#import "PXRoute.h"

@interface PXRouteManager ()

@property (nonatomic, strong) NSMutableDictionary *handlers;
@property (nonatomic, strong) NSMutableDictionary *matchers;

@end


@implementation PXRouteManager

+ (instancetype)defaultManager{
    static id _shareInstance = nil;
    static dispatch_once_t onePredicate;
    dispatch_once(&onePredicate, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.handlers  = [NSMutableDictionary dictionary];
        self.matchers  = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Routes Manager

- (void)registerHander:(PXRouteHandlerBlock)routeHandlerBlock forPath:(NSString *)path
{
    
    if (routeHandlerBlock && [path length]) {
        self.handlers[path] = [routeHandlerBlock copy];
    }
}

- (void)registerHander:(PXRouteHandlerBlock)routeHandlerBlock forPaths:(NSArray<NSString *> *)paths
{
    for (NSString *path in paths) {
        [self registerHander:routeHandlerBlock forPath:path];
    }
}


- (void)unregisterPath:(NSString *)path
{
    [self.handlers removeObjectForKey:path];
    [self.matchers removeObjectForKey:path];
}

#pragma mark - Object Subscripting

- (id)objectForKeyedSubscript:(NSString *)key
{
    NSString *route = (NSString *)key;
    id obj = nil;
    
    if ([route isKindOfClass:[NSString class]] && route.length) {
        obj = self.handlers[route];
    }
    
    return obj;
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    
    NSString *route = (NSString *)key;
    if (!([route isKindOfClass:[NSString class]] && route.length)) {
        return;
    }
    
    if (!obj) {
        [self.handlers removeObjectForKey:route];
    }
    else if ([obj isKindOfClass:NSClassFromString(@"NSBlock")]) {
        [self registerHander:obj forPath:route];
    }
}

- (void)setObject:(id)obj forKeyedListSubscript:(NSArray<NSString *> *)keylist
{
    for (NSString *key in keylist) {
        [self setObject:obj forKeyedSubscript:key];
    }
}

- (void)setHandlerBlock:(PXRouteHandlerBlock)block forKeyedListSubscript:(NSArray<NSString *> *)keylist
{
    for (NSString *key in keylist) {
        [self setObject:block forKeyedSubscript:key];
    }
}

#pragma mark - Shortcut 

- (BOOL)openURLstr:(NSString *)urlstr
{
    return [self openURLstr:urlstr complete:NULL];
}

- (BOOL)openURLstr:(NSString *)urlstr complete:(PXRouteCompleteBlock)complete
{
    return [self openURLstr:urlstr parameters:nil complete:complete];
}

- (BOOL)openURLstr:(NSString *)urlstr parameters:(NSDictionary *)parameters complete:(PXRouteCompleteBlock)complete
{
    NSURL *url = [NSURL URLWithString:urlstr];
    
    if (url) {
        return [self openURL:url parameters:parameters callbackURL:nil complete:complete];
    } else {
        return NO;
    }
}

#pragma mark - check match
- (BOOL)canOpenURLstr:(NSString *)urlstr {
    NSURL *url = [NSURL URLWithString:urlstr];
    if (url) {
        return [self canOpenURL:url];
    }
    return NO;
}

- (BOOL)canOpenURL:(NSURL *)url {
    if (!url) {
        return NO;
    }
    BOOL canOpen = NO;
    PXRoute  *route = [[PXRoute alloc] initWithURL:[url standardizedURL]];
    for (NSString *path in self.handlers.allKeys) {
        PXRouteMatcher *matcher = [self.matchers objectForKey:path];
        
        if (!matcher) {
            matcher = [PXRouteMatcher matcherWithPath:path];
            [self.matchers setObject:matcher forKey:path];
        }
        
        canOpen = [matcher matchRoute:route];
        if (canOpen) break;
    }
    return canOpen;
}

- (NSString *)matchURLstr:(NSString *)urlstr {
    NSURL *url = [NSURL URLWithString:urlstr];
    if (url) {
        return [self matchURL:url];
    }
    return nil;
}

- (NSString *)matchURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    NSString *uri = nil;
    PXRoute  *route = [[PXRoute alloc] initWithURL:[url standardizedURL]];
    for (NSString *path in self.handlers.allKeys) {
        PXRouteMatcher *matcher = [self.matchers objectForKey:path];
        
        if (!matcher) {
            matcher = [PXRouteMatcher matcherWithPath:path];
            [self.matchers setObject:matcher forKey:path];
        }
        
        BOOL isMatch = [matcher matchRoute:route];
        if (isMatch) {
            uri = matcher.route;
            break;
        }
    }
    return uri;
}

- (PXRoute *)parserURLstr:(NSString *)urlstr {
    NSURL *url = [NSURL URLWithString:urlstr];
    if (url) {
        return [self parserURL:url];
    }
    return nil;
}

- (PXRoute *)parserURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    PXRoute  *route = [[PXRoute alloc] initWithURL:[url standardizedURL]];
    for (NSString *path in self.handlers.allKeys) {
        PXRouteMatcher *matcher = [self.matchers objectForKey:path];
        
        if (!matcher) {
            matcher = [PXRouteMatcher matcherWithPath:path];
            [self.matchers setObject:matcher forKey:path];
        }
        
        BOOL isMatch = [matcher matchRoute:route];
        if (isMatch) {
            return route;
        }
    }
    return nil;
}

#pragma mark - Routing

- (BOOL)openURL:(NSURL *)url {
    
    return [self openURL:url complete:NULL];
}

- (BOOL)openURL:(NSURL *)url complete:(PXRouteCompleteBlock)complete
{
    return [self openURL:url callbackURL:nil complete:complete];
}

- (BOOL)openURL:(NSURL *)url callbackURL:(NSURL *)callbackURL complete:(PXRouteCompleteBlock)complete
{
    return [self openURL:url parameters:nil callbackURL:callbackURL complete:complete];
}

- (BOOL)openURL:(NSURL *)url parameters:(NSDictionary *)parameters callbackURL:(NSURL *)callbackURL complete:(PXRouteCompleteBlock)complete
{
    if (!url) {
        return NO;
    }
    
    __autoreleasing PXRoute  *route = [[PXRoute alloc] initWithURL:[url standardizedURL]];
    
    __block BOOL isHandled = NO;
    for (NSString *path in self.handlers.allKeys) {
        PXRouteMatcher *matcher = [self.matchers objectForKey:path];
        
        if (!matcher) {
            matcher = [PXRouteMatcher matcherWithPath:path];
            [self.matchers setObject:matcher forKey:path];
        }
        
        BOOL isMatch = [matcher matchRoute:route];
        if (!isMatch) {
            continue;
        }
        
        route.callbackURL = callbackURL;
        
        if (parameters) {
            NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:route.parameters];
            [mDict addEntriesFromDictionary:parameters];
            route.parameters = [mDict copy];
        }
        
        isHandled = [self handlePath:path withRoute:route];
        
        if (complete) {
            complete(route);
            complete = nil;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(routeManager:didOpenRoute:forPath:)]) {
            [self.delegate routeManager:self didOpenRoute:route forPath:path];
        }
        
        NSString *next = route.parameters[@"next"];
        if (next.length > 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(routeManager:handleNext:forPath:)]) {
                [self.delegate routeManager:self handleNext:route forPath:path];
            }
        }
        
        break;
    }
    return isHandled;
}

- (BOOL)handlePath:(NSString *)path withRoute:(PXRoute *)route {
    id handler = self[path];
    
    if ([handler isKindOfClass:NSClassFromString(@"NSBlock")]) {
        PXRouteHandlerBlock routeHandlerBlock = handler;
        BOOL isHandle = routeHandlerBlock(route);
        return isHandle;

    }
    return NO;
}


#pragma mark -- get router viewController method
- (UIViewController *)viewControllerWithURL:(NSURL *)url
                                 parameters:(NSDictionary *)parameters
                                callbackURL:(NSURL *)callbackURL
                                   complete:(PXRouteCompleteBlock)complete {
    if (!url) {
        return nil;
    }
    
    PXRoute *route = [[PXRoute alloc] initWithURL:[url standardizedURL]];
    for (NSString *path in self.handlers.allKeys) {
        PXRouteMatcher *matcher = [self.matchers objectForKey:path];
        if (!matcher) {
            matcher = [PXRouteMatcher matcherWithPath:path];
            [self.matchers setObject:matcher forKey:path];
        }
        BOOL isMatch = [matcher matchRoute:route];
        if (!isMatch) {
            continue;
        }
        route.callbackURL = callbackURL;
        if (parameters) {
            NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:route.parameters];
            [mDict addEntriesFromDictionary:parameters];
            route.parameters = mDict;
        }
        
        BOOL isHandled = [self handlePath:path withRoute:route];
        if (complete && isHandled) {
            complete(route);
            complete = nil;
        }
        
        if (isHandled
            && (nil != route.viewController)) {
            return route.viewController;
        }
    }
    
    return route.viewController;
}
@end
