//
//  MiKiURINavigationCenter.m
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import "YOYURINavigationCenter.h"
//#import "PXCoreFactory.h"
#import "YOYMediator.h"
#import "URINavigationCenterDefine.h"
#import "YOYCommonServiceCenter.h"

@interface YOYURINavigationCenter() <YOYRouteManagerDelegate>
@property (nonatomic, copy) NSString *uriScheme;
@end

@implementation YOYURINavigationCenter

+ (instancetype)sharedObject
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [YOYRouteManager defaultManager].delegate = self;
    }
    return self;
}

- (void)dealloc
{
    RemoveCoreClientAll(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setURIScheme:(NSString *)urischeme
{
    self.uriScheme = [urischeme copy];
}

- (BOOL)handleURI:(NSString *)URI
{
   return [self handleURI:URI complete:nil];
}

- (BOOL)handleURI:(NSString *)URI
         complete:(nullable YOYRouteCompleteBlock)complete
{
    Protocol *IViewControllerPort = NSProtocolFromString(@"IViewControllerPort");
    id viewController = nil;
//    if (IViewControllerPort) {
//        id vcCore = [PXCoreFactory getMappedCoreFromProtocol:IViewControllerPort];
//        viewController = [[PXMediator sharedInstance] performSingleTarget:vcCore action:@"currentViewController" params:nil onMainThread:NO];
//    }
    return [self handleURI:URI
        fromViewController:viewController
                  animated:YES
                  complete:complete];
}

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
{
    return [self handleURI:URI
        fromViewController:viewController
                  animated:YES
                  complete:nil];
}

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
{
    return [self handleURI:URI
        fromViewController:viewController
                  animated:animated
                  complete:nil];
}

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
         complete:(nullable YOYRouteCompleteBlock)complete
{
    return [self handleURI:URI fromViewController:viewController animated:animated extendInfo:nil complete:complete];
}

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info
{
    return [self handleURI:URI fromViewController:viewController animated:animated extendInfo:info complete:nil];
}

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info
         complete:(nullable YOYRouteCompleteBlock)complete
{
    return [self handleURI:URI fromViewController:viewController animated:animated extendInfo:info complete:complete hasCompatible:NO];
}

- (BOOL)handleURI:(NSString *)URI
fromViewController:(nullable UIViewController *)viewController
         animated:(BOOL)animated
       extendInfo:(nullable NSDictionary *)info
         complete:(nullable YOYRouteCompleteBlock)complete
    hasCompatible:(BOOL)hascompatible
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:info];
    if (viewController) {
        [parameters setObject:viewController forKey:URIViewControllerKey];
        [parameters setObject:@(animated) forKey:URIAnimationKey];
    }
    if (info) {
        [parameters setObject:info forKey:URIExternInfoKey];
    }
    
    @try {
        
        URI = [URI stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *url = [NSURL URLWithString:URI];
        if (url == nil) {
            NSString *uriUTF8 = [URI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            url = [NSURL URLWithString:uriUTF8];
        }
        
        if (URI != nil && url == nil) {
            NSLog(@"Invalid URL %@ ,convert URL Fail!!! ", URI);
        }
        
        BOOL isHandle = [[YOYRouteManager defaultManager] openURL:url parameters:[NSDictionary dictionaryWithDictionary:parameters] callbackURL:nil complete:complete];
        return isHandle;
    } @catch (NSException *exception) {
        return NO;
    }
    
}

- (UIViewController *)viewControllerWithURI:(NSString *)URI
                         fromViewController:(nullable UIViewController *)viewController
                                 extendInfo:(nullable NSDictionary *)info
                                   complete:(nullable YOYRouteCompleteBlock)complete
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:info];
    if (viewController) {
        [parameters setObject:viewController forKey:URIViewControllerKey];
    }
    if (info) {
        [parameters setObject:info forKey:URIExternInfoKey];
    }
    [parameters setObject:@YES forKey:URIActionForGetViewControllerKey];
    
    URI = [URI stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *url = [NSURL URLWithString:URI];//[URI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    if (url == nil) {
        NSString *uriUTF8 = [URI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:uriUTF8];
    }
    
    if (URI != nil && url == nil) {
        NSLog(@"Invalid URL %@ ,convert URL Fail!!! ", URI);
    }
    
    @try {
        UIViewController *tmpViewController = [[YOYRouteManager defaultManager] viewControllerWithURL:url parameters:parameters callbackURL:nil complete:complete];
        return tmpViewController;
    }
    @catch (NSException *exception) {
        NSLog(@"YOYRouteManager get viewController 异常 %@",exception);
        return nil;
    }
    
    return nil;
}

- (BOOL)canRouteURI:(NSString *)uri
{
    return [[YOYRouteManager defaultManager] canOpenURLstr:uri];
}

- (NSString *)matchRouteURI:(NSString *)uri
{
    return [[YOYRouteManager defaultManager] matchURLstr:uri];
}

- (YOYRoute *)parseURI:(NSString *)uri
{
    return [[YOYRouteManager defaultManager] parserURLstr:uri];
}

#pragma mark - Private method
- (NSURL *)transformToURLWithURI:(NSString *)uri
{
    NSLog(@"before transformToURLWithURI:%@", uri);
    //去掉头尾的空格
    NSString *resultURI = [uri stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange urlRange = [resultURI rangeOfString:@"http"];
    if (urlRange.location != NSNotFound && urlRange.location != 0) {
        NSArray *paths = [resultURI componentsSeparatedByString:@"http"];
        if (paths.count == 2) {
            NSString *link = [NSString stringWithFormat:@"http%@", paths[1]];
            
            NSArray *components = [link componentsSeparatedByString:@"/"];
            NSMutableArray *tmpComponents = [NSMutableArray array];
            
            for (NSString *component in components) {
                if ([component hasPrefix:@"http"]) {
                    NSString *encodeLink = [self reEncode:component];
                    if (encodeLink) {
                        [tmpComponents addObject:encodeLink];
                    }
                } else {
                    [tmpComponents addObject:component];
                }
            }
            
            NSString *encodePath = paths[0];
            if ([encodePath hasPrefix:@"/"]) {
                encodePath = [encodePath substringFromIndex:(encodePath.length - 1)];
            }
            for (NSString *component in tmpComponents) {
                encodePath = [NSString stringWithFormat:@"%@/%@", encodePath, component];
            }
            resultURI = encodePath;
        }
    }
    NSURL *url = [NSURL URLWithString:resultURI];
    if (uri == nil) {
        NSString *uriUTF8 = [resultURI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:uriUTF8];
    }
    NSLog(@"After transformToURLWithURI:%@", url);
    return url;
}

- (NSString *)reEncode:(NSString *)string
{
    NSString *firstEncode;
    NSInteger MaxCount = 10;
    // 为了解耦，我们使用这个方法
    NSString *HttpUtilityStr = [[YOYMediator sharedInstance] performClass:@"HttpUtility"
                                                                    action:@"urlDecode"
                                                                    params:string];
    
    while (![[NSURL URLWithString:string] host]) {
        if ([string isEqualToString:HttpUtilityStr] || !MaxCount) {
            break;
        }
        string = HttpUtilityStr;
        MaxCount--;
    }
    firstEncode = string;
    
    // 为了解耦，我们使用这个方法
    NSString *urlEncodeStr = [[YOYMediator sharedInstance] performClass:@"HttpUtility"
                                                                  action:@"urlEncode"
                                                                  params:firstEncode];
    return [[YOYMediator sharedInstance] performClass:@"HttpUtility" action:@"urlEncode" params:urlEncodeStr];
}

#pragma mark - YOYRouteManagerDelegate
- (void)routeManager:(YOYRouteManager *)routeManager didOpenRoute:(YOYRoute *)route forPath:(NSString *)path
{
    NotifyCoreClient(URINavigationCenterClient, @selector(routeManager:didOpenRoute:forPath:), routeManager:routeManager didOpenRoute:route forPath:path);
}

- (void)routeManager:(YOYRouteManager *)routeManager handleNext:(YOYRoute *)route forPath:(NSString *)path
{
    !self.handleNextRouteBlock ?: self.handleNextRouteBlock(route, path);
}

@end
