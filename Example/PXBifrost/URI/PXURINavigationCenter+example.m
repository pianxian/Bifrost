//
//  PXURINavigationCenter+example.m
//  PXBifrost_Example
//
//  Created by 胡伟伟 on 2023/7/13.
//  Copyright © 2023 huweiwei. All rights reserved.
//

#import "PXURINavigationCenter+example.h"
#import "PXURIExampleScene.h"
#import "IViewControllerPort.h"

@import Bifrost;

@implementation YOYURINavigationCenter (example)

RESIGN_ACTION(exampleURI, @[ @"exampleURI/URI" ])
{
    PXURIExampleScene *exampleScene = [PXURIExampleScene new];
    exampleScene.modalPresentationStyle = UIModalPresentationCustom;
    exampleScene.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [YOYGetCoreI(IViewControllerPort).currentViewController presentViewController:exampleScene animated:YES completion:nil];
    return true;
}


@end
