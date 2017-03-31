//
//  HHBadgeViewController.m
//  UIView-HHAddBadge
//
//  Created by YunSL on 17/3/31.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "HHBadgeViewController.h"
#import "UIView+HHAddBadge.h"

@interface HHBadgeViewController ()

@end

@implementation HHBadgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"badge";
    
    //[self.tabBarController setSelectedIndex:0];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"123" style:UIBarButtonItemStylePlain target:self action:@selector(badge)];
    
    self.navigationItem.rightBarButtonItem.hh_titleLabel.hh_badge.value = HHBadgeDot;


    [self.tabBarController.tabBar.items.firstObject hh_titleLabel].hh_badge.value = HHBadgeDot;

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
;
}

- (void)badge {
    self.navigationItem.rightBarButtonItem.hh_titleLabel.hh_badge.value = @(1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
