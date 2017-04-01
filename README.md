## UIView-HHAddBadged
* 使用UIView扩展添加badge
## How to use
* 全局配置
``` objective-c
[UIView hh_setupBadgeApperenceWithBlock:^(HHBadgeView *badgeView) {
    badgeView.font = [UIFont systemFontOfSize:15];
    badgeView.horizontalPosition = HHBadgePositionFooter;
    badgeView.verticalPosition = HHBadgePositionHeader;
}];
```
* xib
``` objective-c
HHBadgeXIBView *xib = [[NSBundle mainBundle] loadNibNamed:@"HHBadgeXIBView" owner:nil options:nil].firstObject;
xib.bounds = CGRectMake(0, 0, 250, 100);
xib.center = CGPointMake(self.view.center.x, 135);
xib.hh_badge.backgroundColor = [UIColor cyanColor];
xib.hh_badge.foregroundColor = [UIColor orangeColor];
xib.hh_badge.contentInsets = UIEdgeInsetsMake(2, 2, 2, 2);
xib.hh_badge.horizontalPosition = HHBadgePositionHeader;
xib.hh_badge.value = @"xib";
xib.hh_badge.boardWidth = 1;
xib.hh_badge.boardColor = [UIColor whiteColor];
xib.xibSwitch.hh_badge.value = [UIColor redColor];
xib.xibSwitch.hh_badge.boardWidth = 1;
xib.xibSwitch.hh_badge.boardColor = [UIColor whiteColor];
xib.xibLabel.hh_badge.value = [UIImage imageNamed:@"小心心"];
xib.xibLabel.hh_badge.backgroundColor = [UIColor clearColor];
xib.backgroundColor = [UIColor orangeColor];
[self.view addSubview:xib];
[self setXibView:xib];
``` 
* code
``` objective-c
UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
btn.titleLabel.hh_badge.value = @"123456";
btn.titleLabel.hh_badge.hh_badge.value = [UIColor whiteColor];
btn.imageView.hh_badge.value = [UIColor yellowColor];
btn.imageView.hh_badge.horizontalPosition = HHBadgePositionFooter;
btn.imageView.hh_badge.verticalPosition = HHBadgePositionHeader;
btn.imageView.hh_badge.anchorPoint = CGPointMake(1, 0);
btn.imageView.hh_badge.size = CGSizeMake(10, 10);
btn.backgroundColor = [UIColor cyanColor];
[btn setTitle:@"UIButton" forState:UIControlStateNormal];
[btn setImage:[UIImage imageNamed:@"任飘渺"] forState:UIControlStateNormal];
[btn sizeToFit];
[btn setCenter:CGPointMake(self.view.center.x, 300)];
[self.view addSubview:btn];
```
* UIBarButtonItem
``` objective-c
self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"UIBarButtonItem" style:UIBarButtonItemStylePlain target:self action:@selector(touchAction)];
self.navigationItem.rightBarButtonItem.hh_titleLabel.hh_badge.value = [UIColor redColor];
```
* UITabBarItem
``` objective-c
[self.tabBarController.tabBar.items.firstObject hh_titleLabel].hh_badge.value = @"UITabBarItem";
[self.tabBarController.tabBar.items.firstObject hh_titleLabel].hh_badge.font = [UIFont systemFontOfSize:8];
[self.tabBarController.tabBar.items.firstObject hh_titleLabel].hh_badge.anchorPoint = CGPointMake(0, 0.5);
```
* HHBadgeView
``` objective-c
HHBadgeView *badgeView = [HHBadgeView badgeViewWithParentView:self.tabBarController.tabBar];
badgeView.value = @"1";
badgeView.horizontalPosition = HHBadgePositionCenter;
```
* 运行结果
<img alt="ScreenShot BarButtonItem" src="http://img0.ph.126.net/4DlCe-xpPqCsUXaAGS1TYQ==/6632258536791836259.png" width="320px"/>
