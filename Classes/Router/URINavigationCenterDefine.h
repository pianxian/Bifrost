//
//  URINavigationCenterDefine.h
//  Bifrost
//
//  Created by pianxian on 2023/2/28.
//  Copyright © 2023 MiKi Inc. All rights reserved.
//

#ifndef URINavigationCenterDefine_h
#define URINavigationCenterDefine_h

#import "YOYRouteManager.h"
#import "YOYURINavigationCenter.h"
#import "YOYRoute.h"

#define KEY(key) @#key

static NSString * const URIViewControllerKey = @"URIViewControllerKey";
static NSString * const URIAnimationKey = @"URIAnimationKey";
static NSString * const URIExternInfoKey = @"URIExternInfoKey";
static NSString * const URIActionForGetViewControllerKey = @"URIActionForGetViewControllerKey";

static NSString * const ResignPrefixIndentifier = @"_UriNavigationCenterResign";
static NSString * const URIRouteRegisterKey = @"URIRouteRegisterKey";


#endif /* URINavigationCenterDefine_h */

@protocol URINavigationCenterClient <NSObject>

@optional
- (void)routeManager:(YOYRouteManager *)routeManager didOpenRoute:(YOYRoute *)route forPath:(NSString *)path;
@end
