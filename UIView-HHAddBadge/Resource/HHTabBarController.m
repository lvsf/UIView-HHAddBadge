//
//  HHTabBarController.m
//  UIView-HHAddBadge
//
//  Created by YunSL on 17/4/20.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "HHTabBarController.h"
#import "UIView+HHAddBadge.h"

@interface HHTabBarController ()

@end

@implementation HHTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    item.hh_imageView.hh_badge.value = @(arc4random_uniform(100));
    item.hh_imageView.hh_badge.anchorPoint = CGPointMake(0, 0.5);
}

@end
