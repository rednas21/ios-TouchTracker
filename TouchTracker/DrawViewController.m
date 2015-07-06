//
//  DrawViewController.m
//  TouchTracker
//
//  Created by Sander Peerna on 7/6/15.
//  Copyright (c) 2015 Sander Peerna. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"

@interface DrawViewController ()

@end

@implementation DrawViewController

- (void)loadView
{
    self.view = [[DrawView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
