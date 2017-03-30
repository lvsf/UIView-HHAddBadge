//
//  ViewController.m
//  UIView-HHAddBadge
//
//  Created by YunSL on 17/3/29.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "ViewController.h"
#import "UIView+HHAddBadge.h"

@interface ViewController ()
@property (nonatomic,strong) UIButton *btn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIView hh_badgeApperence].backgroudColor = [UIColor blueColor];

    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn hh_updateBadgeValue:@"123"];
    [btn setTitle:@"HHAddBadge" forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn setCenter:self.view.center];
    [btn setBackgroundColor:[UIColor orangeColor]];
    
    [btn.titleLabel hh_updateBadgeValue:[UIColor redColor] apperence:^(HHBadgeApperence *apperence) {
        apperence.horizontalPosition = HHBadgePositionHeader;
    }];
    
    [self.view addSubview:btn];
    [self setBtn:btn];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.btn hh_updateBadgeValue:nil apperence:^(HHBadgeApperence *apperence) {
        apperence.backgroudColor = [UIColor purpleColor];
        apperence.font = [UIFont systemFontOfSize:20];
    }];
}

@end
