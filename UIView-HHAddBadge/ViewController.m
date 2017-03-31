//
//  ViewController.m
//  UIView-HHAddBadge
//
//  Created by YunSL on 17/3/29.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "ViewController.h"
#import "UIView+HHAddBadge.h"
#import "UIView+HHAddBadge.h"
#import "HHBadgeViewController.h"

@interface ViewController ()
@property (nonatomic,strong) UIButton *btn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    CALayer *l = [CALayer new];
//    l.backgroundColor = [UIColor orangeColor].CGColor;
//    l.contents = (id)@"123";
//    l.frame = CGRectMake(0, 0, 100, 50);
//    [self.view.layer addSublayer:l];
    
    
    
    //[UIView hh_badgeApperence].backgroudColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor lightGrayColor];
    


    //[HHBadgeView appearance].
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[btn hh_updateBadgeValue:@"aaaaa"];
    

    [UIView hh_registBadgeApperenceWithBlock:^(HHBadgeView *badgeView) {
        badgeView.horizontalPosition = HHBadgePositionFooter;
        badgeView.foregroundColor = [UIColor whiteColor];
        badgeView.boardColor = [UIColor whiteColor];
        badgeView.boardWidth = 1;
        badgeView.badgeColor = [UIColor redColor];
        badgeView.font = [UIFont systemFontOfSize:13];
    }];
    
    
    btn.hh_badge.value = @"1";
    btn.hh_badge.badgeColor = [UIColor greenColor];
    btn.hh_badge.boardWidth = 1;
    btn.hh_badge.boardColor = [UIColor whiteColor];
    
    [btn setTitle:@"HHAddBadge" forState:UIControlStateNormal];
    //[btn setImage:[UIImage imageNamed:@"小叶子"] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn setCenter:self.view.center];
    [btn setBackgroundColor:[UIColor orangeColor]];


    //btn.titleLabel.hh_badge.value = @"123";
    
   // btn.imageView.hh_badge.value = @"asd";
    
//    [btn.titleLabel hh_updateBadgeValue:[UIColor redColor] apperence:^(HHBadgeApperence *apperence) {
//        apperence.horizontalPosition = HHBadgePositionHeader;
//    }];
    
    [btn addTarget:self action:@selector(touch) forControlEvents:UIControlEventTouchDown];
    

    
    UIView *v = [UIView new];

    
    [self.view addSubview:v];
    
    [v addSubview:btn];
    [self setBtn:btn];
    
    

    
    v.backgroundColor = [UIColor cyanColor];
    v.frame = self.view.bounds;
    //btn.hh_badge.badgeColor = [UIColor greenColor];

    

    

}

- (void)touch {

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //self.btn.titleLabel.hh_badge.layer.cornerRadius = 5;
    
    self.btn.hh_badge.value = [UIColor orangeColor];
    //self.btn.hh_badge.size = CGSizeMake(20, 20);
    self.btn.hh_badge.boardWidth = 5;
    self.btn.hh_badge.boardColor = [UIColor redColor];
    
   // self.btn.titleLabel.hh_badge.layer.cornerRadius = arc4random_uniform(20);
   // self.btn.titleLabel.hh_badge.value = @(arc4random_uniform(200));
}

@end
