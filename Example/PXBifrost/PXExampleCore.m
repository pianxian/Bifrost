//
//  PXExampleCore.m
//  PXBifrost_Example
//
//  Created by 胡伟伟 on 2023/7/13.
//  Copyright © 2023 huweiwei. All rights reserved.
//

#import "PXExampleCore.h"
//编译时注册进二进制data字段
YOY_CORE_REGISTER(IPXExampleCore, PXExampleCore);


@interface PXExampleCore()<IPXExampleCore>

@end
@implementation PXExampleCore
IMPLEMENT_COREPROTOCOL

-(void)helloWorld{
    NSLog(@"helloWorld");
}
@end
