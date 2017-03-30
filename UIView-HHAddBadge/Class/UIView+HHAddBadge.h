//
//  UIView+HHAddBadge.h
//  UIView+HHAddBadge
//
//  Created by YunSL on 17/3/10.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import <UIKit/UIKit.h>

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

/**
 badge的类型
 
 - HHBadgeTypeNot:    无
 - HHBadgeTypeNumber: 数字
 - HHBadgeTypeText:   文本
 - HHBadgeTypeImage:  图片
 - HHBadgeTypeDot:    小圆点
 - HHBadgeTypeCustom: 自定义
 */
typedef NS_ENUM(NSInteger,HHBadgeType) {
    HHBadgeTypeNot = 0,
    HHBadgeTypeNumber,
    HHBadgeTypeText,
    HHBadgeTypeImage,
    HHBadgeTypeDot,
    HHBadgeTypeCustomView
};

#pragma mark - HHBadgeDisplayRule
@class HHBadgeApperence;
@protocol HHBadgeDisplayRule <NSObject>
@optional
/**
 调整badge显示容器的样式/可以在此处设置显示的圆角,边线,阴影...

 @param displayContainer      badge显示容器
 @param displayContainerSize badge显示容器的当前size
 @param badgeType             badge类型
 @param apperence             badge的样式模型
 @return 调整badge显示容器的frame
 */
- (CGSize)badgeDisplayContainer:(UIView*)displayContainer
                 adjustWithSize:(CGSize)displayContainerSize
                   andBadgeType:(HHBadgeType)badgeType
                   andApperence:(HHBadgeApperence*)apperence;
@end

#pragma mark - HHBadgeDisplayRule
@interface HHBadgeDisplayRule : NSObject<HHBadgeDisplayRule>
@end

#pragma mark - HHBadgeApperence
@interface HHBadgeApperence : NSObject<NSCopying>
/**
 附属视图显示规则
 */
@property (nonatomic,weak) id <HHBadgeDisplayRule> displayRule;
/**
 附属视图默认显示规则
 */
@property (nonatomic,strong,readonly) HHBadgeDisplayRule *defaultDisplayRule;
/**
 附属视图主题色
 */
@property (nonatomic,strong) UIColor *tintColor;
/**
 附属视图背景颜色
 */
@property (nonatomic,strong) UIColor *backgroudColor;
/**
 附属视图背景图片
 */
@property (nonatomic,strong) UIImage *backgroudImage;
/**
 附属视图的字体(当hh_badgeValue为NSNumber或NSString时有效)
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
 附属视图中心点相对父视图的偏移量
 */
@property (nonatomic,assign) UIEdgeInsets centerOffsetInsets;
/**
 附属视图内边距
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
 重置为默认参数
 */
- (void)reset;
@end

#pragma mark - API
@interface UIView (HHAddBadge)
@property (nonatomic,strong) id hh_badgeValue;
@property (nonatomic,strong,readonly) UIView *hh_badgeView;
@property (nonatomic,assign,readonly) CGRect hh_badgeViewFrame;
@property (nonatomic,assign,readonly) CGRect hh_badgeDisplayContainerFrame;
+ (HHBadgeApperence*)hh_badgeApperence;
- (void)hh_remove;
- (void)hh_updateBadgeValue:(id)badgeValue;
- (void)hh_updateBadgeValue:(id)badgeValue
                  apperence:(void(^)(HHBadgeApperence *apperence))apperenceBlock;
- (void)hh_updateApperence:(void(^)(HHBadgeApperence *apperence))apperenceBlock;
@end
