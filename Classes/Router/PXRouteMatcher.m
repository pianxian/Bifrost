//
//  PXRouteMatcher.m
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#import "PXRouteMatcher.h"

static NSString * const PXRouteParameterPattern = @":[a-zA-Z0-9-_%]+";
static NSString * const PXURLParameterPattern = @"([^/]+)";

@interface PXRouteMatcher ()

@property (nonatomic, copy)   NSString  *route;
@property (nonatomic, strong) NSRegularExpression *regex;
@property (nonatomic, strong) NSMutableArray *routeParamaterNames;
@property (nonatomic, strong) NSString *pathComponent;
@end

@implementation PXRouteMatcher

+ (instancetype)matcherWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path];
}


- (instancetype)initWithPath:(NSString *)route {
    if (![route length]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _route = route;
    }
    
    return self;
}

- (NSString *)pathComponent {
    if (_pathComponent == nil) {
        NSString *pattern = self.route;
        NSURL *URL = [NSURL URLWithString:self.route];
        NSString *scheme = URL.scheme;
        
        if (scheme.length > 0) {
            NSString *deleteSchemeStr = [NSString stringWithFormat:@"%@://", scheme];
            pattern = [pattern stringByReplacingOccurrencesOfString:deleteSchemeStr withString:@""];
        }
       
        if ([self.route characterAtIndex:0] == '/') {
            pattern = [pattern substringFromIndex:1];
        }
        
        NSRange range = [pattern rangeOfString:@"/:"];
        if (range.location != NSNotFound) {
            pattern = [pattern substringToIndex:range.location];
        }
        _pathComponent = pattern;
    }
    return _pathComponent;
}

- (NSRegularExpression *)regex {
    if (!_regex) {
        _routeParamaterNames = [NSMutableArray array];
        NSRegularExpression *parameterRegex = [NSRegularExpression regularExpressionWithPattern:PXRouteParameterPattern
                                                                                        options:0
                                                                                          error:nil];
        
        NSString *modifiedRoute = [self.route copy];
        NSArray *matches = [parameterRegex matchesInString:self.route
                                                   options:0
                                                     range:NSMakeRange(0, self.route.length)];
        
        for (NSTextCheckingResult *result in matches) {
            
            NSString *stringToReplace   = [self.route substringWithRange:result.range];
            NSString *variableName      = [stringToReplace stringByReplacingOccurrencesOfString:@":"
                                                                                     withString:@""];
            [self.routeParamaterNames addObject:variableName];
            
            modifiedRoute = [modifiedRoute stringByReplacingOccurrencesOfString:stringToReplace
                                                                     withString:PXURLParameterPattern];
        }
        
        modifiedRoute = [modifiedRoute stringByAppendingString:@"$"];
        _regex = [NSRegularExpression regularExpressionWithPattern:modifiedRoute
                                                           options:NSRegularExpressionCaseInsensitive   //注意匹配不区分大小写，因为openURL有时会把url的host部分大写转成小写
                                                             error:nil];
    }
    
    return _regex;
}


- (BOOL)matchRoute:(PXRoute *)route {
    if (route.destURL.query) {
        // 标准URI走新匹配方式 sango://MainHome/Tab?category=1&subCategory=2，
        @try {
            BOOL isMatchScheme = NO;
            BOOL isMatchSucceed = [self matchStandardURIWithRoute:route isMatchScheme:&isMatchScheme];
            if (isMatchSucceed == NO) {
                // 但是对于 sango://Channel/Live/45294452/452294452?tpl=16777217则需要走老匹配方式
                isMatchSucceed = [self matchOldURIWithRoute:route];
            }
            return isMatchSucceed && isMatchScheme;
        }
        @catch (NSException *exception){
#ifdef DEBUG
            [PXRouteMatcher showExceptionAlert];
#endif
            return NO;
        }
    }else {
        return [self matchOldURIWithRoute:route];
    }
}

#pragma mark -- 标准URI匹配方式   如：sango://MainHome/Tab?category=1&subCategory=2
- (BOOL)matchStandardURIWithRoute:(PXRoute *)route isMatchScheme:(BOOL *)isMatchScheme {
    NSString *routeString = route.destURL.standardizedURL.absoluteString;
    NSMutableString *pathCompoment = [NSMutableString stringWithString:@""];
    [pathCompoment appendString:route.destURL.host ?: @""];
    pathCompoment = [[pathCompoment stringByAppendingPathComponent:route.destURL.path ?: @""] mutableCopy];
    // openUrl打开app时，有时会把host部分的大写换成小写
    
    if (isMatchScheme) {
        NSString *rhsScheme = route.destURL.scheme;
        BOOL hasScheme = rhsScheme.length > 0;
        if (hasScheme) {
            NSString *lhsScheme = [[NSURL URLWithString:self.route] scheme];
            *isMatchScheme = NSOrderedSame == [lhsScheme compare:rhsScheme options:NSCaseInsensitiveSearch];
        } else { // 兼容注册时没有注册 scheme 情况
            *isMatchScheme = YES;
        }
    }
    
    if (([pathCompoment compare:self.pathComponent options:NSCaseInsensitiveSearch] == NSOrderedSame) && pathCompoment) {
        NSURLComponents *components = [NSURLComponents componentsWithString:routeString];
        NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
        for (NSURLQueryItem *queryItem in components.queryItems) {
            if (queryItem.value && queryItem.name) {
                [routeParameters setValue:queryItem.value forKey:queryItem.name];
            }
        }
        route.parameters = routeParameters;
        
        return YES;
    }
    
    return NO;
}

#pragma mark -- 标准URI匹配方式   如：sango://MainHome/Tab/1/2 或 sango://MainHome/Tab/1/2?params=3 对应注册URI：MainHome/Tab/:category/:subCategory
- (BOOL)matchOldURIWithRoute:(PXRoute *)route {
    NSString *routeString = route.destURL.standardizedURL.absoluteString;
    if (route.destURL.query) {
        NSString *pathCompoment = route.destURL.host;
        routeString = [pathCompoment stringByAppendingPathComponent:route.destURL.path];
    }
    
    routeString = routeString ?: @"";
    NSArray *matches      = [self.regex matchesInString:routeString
                                                options:0
                                                  range:NSMakeRange(0, routeString.length)];
    
    BOOL hostMatch = [self hostMatch:route.destURL];
    BOOL hostScheme = [self schemeMatch:route.destURL];
    
    if (!matches.count || !hostMatch || !hostScheme) {
        return NO;
    }
    
    NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
    for (NSTextCheckingResult *result in matches) {
        
        for (int i = 1; i < result.numberOfRanges && i <= self.routeParamaterNames.count; i++) {
            NSString *parameterName         = self.routeParamaterNames[i - 1];
            NSString *parameterValue        = [routeString substringWithRange:[result rangeAtIndex:i]];
            routeParameters[parameterName]  = [parameterValue stringByRemovingPercentEncoding];
        }
    }
    
    if (route.destURL.query) {
        NSURLComponents *components = [NSURLComponents componentsWithString:route.destURL.standardizedURL.absoluteString];
        NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
        for (NSURLQueryItem *queryItem in components.queryItems) {
            if (queryItem.value && queryItem.name) {
                [routeParameters setValue:queryItem.value forKey:queryItem.name];
            }
        }
    }
    
    route.parameters = routeParameters;
    
    return YES;
}

// 兼容手 Y 逻辑 scheme 或 host 字符串匹配
- (BOOL)hostMatch:(NSURL *)rhsURL
{
    NSString *rhsHost = rhsURL.host;
    if (rhsHost.length <= 0) {
        return YES;
    }
    NSURL *lhsURL = [NSURL URLWithString:self.route];
    if (lhsURL) {
        NSString *lhsHost = lhsURL.host ?: lhsURL.pathComponents.firstObject;
        if (lhsHost.length <= 0) {
            return YES;
        }
        
        return [lhsHost caseInsensitiveCompare:rhsHost] == NSOrderedSame;
    }
    
    return YES;
}

- (BOOL)schemeMatch:(NSURL *)rhsURL
{
    NSString *rhsScheme = rhsURL.scheme;
    if (rhsScheme.length <= 0) {
        return YES;
    }
    NSURL *lhsURL = [NSURL URLWithString:self.route];
    if (lhsURL) {
        NSString *lhsScheme = lhsURL.scheme ?: @"";
        if (lhsScheme.length <= 0) {
            return YES;
        }
        
        return [lhsScheme caseInsensitiveCompare:rhsScheme] == NSOrderedSame;
    }
    
    return YES;
}

#pragma mark - Debug
+ (void)showExceptionAlert
{
#ifdef DEBUG
    static BOOL canShow = YES;
    if (!canShow) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        canShow = NO;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PXRouter 发生异常"
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleAlert];
         [alertController addAction:[UIAlertAction actionWithTitle:@"好的"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
             canShow = YES;
        }]];
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
#endif
}

@end
