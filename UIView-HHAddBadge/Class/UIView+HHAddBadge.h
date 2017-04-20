//
//  UIView+HHAddBadge.h
//  UIView-HHAddBadge
//
//  Created by YunSL on 17/3/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HHBadgeDot [UIColor redColor]

/**
 附属视图相对依附对象的位置
 
 - HHBadgePositionCenter: 居中
 - HHBadgePositionHeader: 头部
 - HHBadgePositionFooter: 尾部
 */
typedef NS_ENUM(NSInteger,HHBadgePosition) {
    HHBadgePositionCenter = 1,
    HHBadgePositionHeader,
    HHBadgePositionFooter
};

@interface HHBadgeView : UIView
/**
 附属视图的值/NSString/NSNumer/UIColor/UIImage/UIView
 */
@property (nonatomic,strong) id value;
/**
 附属视图前景色/文本颜色,默认为[UIColor whiteColor]
 */
@property (nonatomic,strong) UIColor *foregroundColor;
/**
 附属视图的圆角属性,默认为视图高度一半
 */
@property (nonatomic,assign) CGFloat cornerRadius;
/**
 附属视图的边线颜色,默认为nil
 */
@property (nonatomic,strong) UIColor *boardColor;
/**
 附属视图的边线宽度,默认为0
 */
@property (nonatomic,assign) CGFloat boardWidth;
/**
 附属视图的字体/当hh_badgeValue为NSNumber或NSString时有效,默认为[UIFont systemFontOfSize:15]
 */
@property (nonatomic,strong) UIFont *font;
/**
 附属视图相对父视图的锚点,取值范围0~1,默认{0.5,0.5}
 */
@property (nonatomic,assign) CGPoint anchorPoint;
/**
 附属视图相对父视图水平方向的位置,默认HHBadgePositionFooter
 */
@property (nonatomic,assign) HHBadgePosition horizontalPosition;
/**
 附属视图相对父视图垂直方向的位置,默认HHBadgePositionHeader
 */
@property (nonatomic,assign) HHBadgePosition verticalPosition;
/**
 附属视图中心点相对父视图的偏移量,默认为UIEdgeInsetsZero
 */
@property (nonatomic,assign) UIEdgeInsets centerOffsetInsets;
/**
 附属视图内边距,默认为UIEdgeInsetsZero
 */
@property (nonatomic,assign) UIEdgeInsets contentInsets;
/**
 附属视图指定原点,优先使用
 */
@property (nonatomic,assign) CGPoint origin;
/**
 附属视图指定宽高,优先使用
 */
@property (nonatomic,assign) CGSize size;
/**
 初始化一个HHBadgeView,将自动添加到parentView上

 @param parentView 添加的对象视图
 @return HHBadgeView
 */
+ (instancetype)badgeViewWithParentView:(UIView*)parentView;
@end

@interface UIView (HHAddBadge)
/**
 懒加载的HHBadgeView
 */
@property (nonatomic,strong) HHBadgeView *hh_badge;
/**
 HHBadgeView全局配置/init时调用

 @param apperenceBlock 配置Block
 */
+ (void)hh_setupBadgeApperenceWithBlock:(void(^)(HHBadgeView *badgeView))apperenceBlock;
/**
 移除当前HHBadgeView
 */
- (void)hh_removeBadge;
@end

@interface UIBarItem(HHAddBadge)
/**
 UIBarItem对应的view/UIBarItem->view

 @return UIView
 */
- (UIView*)hh_view;
/**
 UIBarItem上的图片视图

 @return UIImageView
 */
- (UIImageView *)hh_imageView;
/**
 UIBarItem上的文本视图
 
 @return UIImageView
 */
- (UILabel *)hh_titleLabel;
@end
