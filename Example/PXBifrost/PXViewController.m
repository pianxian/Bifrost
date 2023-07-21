//
//  PXViewController.m
//  PXBifrost
//
//  Created by huweiwei on 07/12/2023.
//  Copyright (c) 2023 huweiwei. All rights reserved.
//

#import "PXViewController.h"
#import "IPXExampleCore.h"
#import "PXURINavigationCenter+example.h"

@import PXBifrost;

@interface PXViewController ()

@end

@implementation PXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)example:(UIButton *)sender {
    [PXGetCoreI(IPXExampleCore) helloWorld];
}

- (IBAction)pushScene:(id)sender {
    [PXURINavigationCenter.sharedObject handleURI:@"pxExample://exampleURI/URI"];
}


@end
