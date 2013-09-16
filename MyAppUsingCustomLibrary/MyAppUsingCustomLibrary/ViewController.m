//
//  ViewController.m
//  MyAppUsingCustomLibrary
//
//  Created by Julien Bennamias on 16/09/13.
//  Copyright (c) 2013 Julien Bennamias. All rights reserved.
//

#import "ViewController.h"
#import "UIImage-Custom.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    MyCustomObject *obj = [[MyCustomObject alloc] init];
    [obj aMethod];
    [obj release];
    
    UIImage *img = [[UIImage alloc] init];
    NSLog(@"hasAlpha ? %i", [img hasAlpha]);
    [img release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
