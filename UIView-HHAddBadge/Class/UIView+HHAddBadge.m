//
//  UIView+HHAddBadge.m
//  UIView-HHAddBadge
//
//  Created by YunSL on 17/3/30.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "UIView+HHAddBadge.h"
#import <objc/runtime.h>

#define HHBadgeViewDefaultCornerRadius -1
#define HHBadgeViewLayoutDefaultOrigin CGPointMake(-1, -1)
#define HHBadgeViewLayoutDefaultSize CGSizeMake(-1, -1)
#define HHBadgeViewLayoutDefaultDotSize CGSizeMake(5, 5)

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

static inline CGSize HHBadgeTextSize(NSString *text, UIFont *font) {
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil].size;
    size.width += font.lineHeight * 0.3;
    if (size.width < size.height) {
        size.width = size.height;
    }
    return size;
};

static inline NSArray* HHBadgeNeedDisplayObserveKeyPaths(){
    return @[@"anchorPoint",@"origin",@"size",@"parentFrame",@"boardWidth",
             @"contentInsets",@"centerOffsetInsets",@"horizontalPosition",@"verticalPosition",
             @"value",@"font",@"foregroundColor",@"badgeColor",@"boardColor",@"backgroudImage",@"cornerRadius"];
};

static inline NSArray* HHBadgeNeedLayoutObserveKeyPaths(){
    return @[@"anchorPoint",@"origin",@"size",@"parentFrame",@"boardWidth",
             @"contentInsets",@"centerOffsetInsets",@"horizontalPosition",@"verticalPosition",
             @"value",@"font",@"backgroudImage"];
};

@interface HHBadgeView()
@property (nonatomic,weak) UIView *parentView;
@property (nonatomic,assign) CGRect parentFrame;
@property (nonatomic,assign) HHBadgeType badgeType;
@property (nonatomic,assign) CGRect contentFrame;
@end

@implementation HHBadgeView

#pragma mark - life

+ (instancetype)badgeViewWithParentView:(UIView *)parentView {
    //1.初始化
    HHBadgeView *badgeView = [HHBadgeView new];
    [badgeView setParentFrame:parentView.frame];
    [badgeView setParentView:parentView];
    //2.添加到合适的父视图上
    UIView *containView = parentView.superview?:parentView;
    [containView addSubview:badgeView];
    [parentView setHh_badge:badgeView];
    return badgeView;
}

- (void)dealloc {
    [HHBadgeNeedDisplayObserveKeyPaths() enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:self forKeyPath:obj];
    }];
}

- (instancetype)init {
    if (self = [super init]) {
        //1.默认值
        self.backgroundColor = [UIColor clearColor];
        self.size = HHBadgeViewLayoutDefaultSize;
        self.origin = HHBadgeViewLayoutDefaultOrigin;
        self.cornerRadius = HHBadgeViewDefaultCornerRadius;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.horizontalPosition = HHBadgePositionFooter;
        self.verticalPosition = HHBadgePositionHeader;
        self.boardWidth = 0;
        self.centerOffsetInsets = UIEdgeInsetsZero;
        self.contentInsets = UIEdgeInsetsZero;
        self.font = [UIFont systemFontOfSize:15];
        self.boardColor = [UIColor clearColor];
        self.badgeColor = [UIColor redColor];
        self.foregroundColor = [UIColor whiteColor];
        self.backgroudImage = nil;
        //2.全局设置
        void (^apperenceBlock)() = objc_getAssociatedObject([UIApplication sharedApplication],@selector(hh_registBadgeApperenceWithBlock:));
        if (apperenceBlock) {
            apperenceBlock(self);
        }
        //3.监听变化
        [HHBadgeNeedDisplayObserveKeyPaths() enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addObserver:self
                   forKeyPath:obj
                      options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                      context:nil];
        }];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    id newValue = change[@"new"];
    id oldValue = change[@"old"];
    if (newValue || oldValue) {
        if (![newValue isEqual:oldValue]) {
            if ([HHBadgeNeedLayoutObserveKeyPaths() containsObject:keyPath]) {
                [self handleUpdateLayout];
            }
            [self setNeedsDisplay];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    if (CGRectGetWidth(rect) > 0 &&
        CGRectGetHeight(rect) > 0) {
        void (^drawText)(NSString*, CGRect) = ^(NSString *text, CGRect rect) {
            NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
            [paragraph setAlignment:NSTextAlignmentCenter];
            [text drawWithRect:rect
                       options:(NSStringDrawingUsesLineFragmentOrigin|
                                NSStringDrawingUsesFontLeading)
                    attributes:@{NSFontAttributeName:self.font,
                                 NSForegroundColorAttributeName:self.foregroundColor,
                                 NSParagraphStyleAttributeName:paragraph}
                       context:nil];
        };
        void (^drawImage)(UIImage* ,CGRect) = ^(UIImage *image, CGRect rect) {
            [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1];
        };
        void (^drawRoundedRect)(UIColor*, CGRect, CGFloat) = ^(UIColor *color, CGRect rect, CGFloat cornerRadius) {
            [color setFill];
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
            [path fill];
        };
        
        CGRect boardRect = CGRectInset(rect, self.boardWidth, self.boardWidth);
        CGFloat containerCornerRadius = (self.cornerRadius != HHBadgeViewDefaultCornerRadius)?self.cornerRadius:CGRectGetHeight(rect) * 0.5;
        CGFloat boardCornerRadius = (self.cornerRadius != HHBadgeViewDefaultCornerRadius)?self.cornerRadius:CGRectGetHeight(boardRect) * 0.5;
        UIColor *badgeColor = (self.badgeType == HHBadgeTypeDot)?self.value:self.badgeColor;
        if (self.boardWidth > 0) {
            drawRoundedRect(self.boardColor,rect,containerCornerRadius);
        }
        drawRoundedRect(badgeColor,boardRect,boardCornerRadius);
        
        switch (self.badgeType) {
            case HHBadgeTypeText:drawText(self.value,_contentFrame);break;
            case HHBadgeTypeNumber:drawText([self.value stringValue],_contentFrame);break;
            case HHBadgeTypeImage:drawImage(self.value,_contentFrame);break;
            case HHBadgeTypeDot:;break;
            default:break;
        }
    }
}

#pragma mark - private
- (void)handleUpdateLayout {
    CGRect containerFrame = CGRectZero;
    CGRect parentFrame = self.parentFrame;
    if (CGRectGetWidth(parentFrame) > 0 && CGRectGetHeight(parentFrame) > 0) {
        if (!CGSizeEqualToSize(self.size, HHBadgeViewLayoutDefaultSize)) {
            containerFrame.size = self.size;
        } else {
            CGRect contentFrame = CGRectZero;
            switch (self.badgeType) {
                case HHBadgeTypeNumber:
                    contentFrame.size = HHBadgeTextSize([self.value stringValue], self.font);
                    break;
                case HHBadgeTypeText:
                    contentFrame.size = HHBadgeTextSize(self.value, self.font);
                    break;
                case HHBadgeTypeDot:
                    contentFrame.size = HHBadgeViewLayoutDefaultDotSize;
                    break;
                case HHBadgeTypeImage:
                    contentFrame.size = [(UIImage*)self.value size];
                    break;
                case HHBadgeTypeCustomView:
                    contentFrame.size = [(UIView*)self.value bounds].size;
                    break;
                default:
                    break;
            }
            containerFrame.size = CGSizeMake(CGRectGetWidth(contentFrame) + self.contentInsets.left + self.contentInsets.right + self.boardWidth * 2, CGRectGetHeight(contentFrame) + self.contentInsets.top + self.contentInsets.bottom + self.boardWidth * 2);
        }
        
        if (!CGPointEqualToPoint(self.origin, HHBadgeViewLayoutDefaultOrigin)) {
            containerFrame.origin = self.origin;
        } else {
            CGFloat containX = 0;
            CGFloat containY = 0;
            switch (self.horizontalPosition)
            {
                case HHBadgePositionHeader:containX = 0;break;
                case HHBadgePositionCenter:containX = CGRectGetWidth(parentFrame) * 0.5;break;
                case HHBadgePositionFooter:containX = CGRectGetWidth(parentFrame);break;
                default:break;
            }
            switch (self.verticalPosition)
            {
                case HHBadgePositionHeader:containY = 0;break;
                case HHBadgePositionCenter:containY = CGRectGetHeight(parentFrame) * 0.5;break;
                case HHBadgePositionFooter:containY = CGRectGetHeight(parentFrame);break;
                default:break;
            }
            CGFloat anchorPointX = MIN(1,MAX(0, self.anchorPoint.x));
            CGFloat anchorPointY = MIN(1,MAX(0, self.anchorPoint.y));
            containX = containX - anchorPointX * CGRectGetWidth(containerFrame);
            containX = containX + self.centerOffsetInsets.left - self.centerOffsetInsets.right;
            containY = containY - anchorPointY * CGRectGetHeight(containerFrame);
            containY = containY + self.centerOffsetInsets.top - self.centerOffsetInsets.bottom;
            containerFrame.origin = CGPointMake(containX, containY);
            if ([self.parentView.superview isEqual:self.superview]) {
                containerFrame.origin = [self.parentView.superview convertPoint:containerFrame.origin fromView:self.parentView];
            }
        }
    }

    _contentFrame.origin = CGPointMake(self.contentInsets.left + self.boardWidth, self.contentInsets.top + self.boardWidth);
    _contentFrame.size = CGSizeMake(CGRectGetWidth(containerFrame) - self.contentInsets.left - self.contentInsets.right - 2 * self.boardWidth, CGRectGetHeight(containerFrame) - self.contentInsets.top - self.contentInsets.bottom - 2 * self.boardWidth);
    
    self.frame = containerFrame;
}

#pragma mark - set/get
- (void)setValue:(id)value {
    _value = value;
    _badgeType = HHBadgeTypeNot;
    //1.数字类型
    if ([value isKindOfClass:[NSNumber class]]) {
        _badgeType = HHBadgeTypeNumber;
    }
    //2.文本类型
    if ([value isKindOfClass:[NSString class]]) {
        _badgeType = HHBadgeTypeText;
    }
    //3.图片类型
    if ([value isKindOfClass:[UIImage class]]) {
        _badgeType = HHBadgeTypeImage;
    }
    //5.颜色类型
    if ([value isKindOfClass:[UIColor class]]) {
        _badgeType = HHBadgeTypeDot;
    }
    //6.视图类型
    if ([value isKindOfClass:[UIView class]]) {
        _badgeType = HHBadgeTypeCustomView;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
}

@end

@implementation UIView (HHAddBadge)

+ (void)load {
    SEL originalSEL = @selector(setFrame:);
    SEL newSEL = @selector(hh_swizzle_setFrame:);
    Method originalMethod = class_getInstanceMethod(self, originalSEL);
    Method newMethod = class_getInstanceMethod(self, newSEL);
    class_addMethod(self,
                    originalSEL,
                    class_getMethodImplementation(self, originalSEL),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSEL,
                    class_getMethodImplementation(self, newSEL),
                    method_getTypeEncoding(newMethod));
    method_exchangeImplementations(class_getInstanceMethod(self, originalSEL),
                                   class_getInstanceMethod(self, newSEL));
}

+ (void)hh_registBadgeApperenceWithBlock:(void (^)(HHBadgeView *))apperenceBlock {
    objc_setAssociatedObject([UIApplication sharedApplication], _cmd, apperenceBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)hh_swizzle_setFrame:(CGRect)frame {
    [self hh_swizzle_setFrame:frame];
    if (objc_getAssociatedObject(self, @selector(hh_badge))) {
        self.hh_badge.parentFrame = frame;
    }
}

- (void)hh_remove {
    self.hh_badge = nil;
}

- (void)setHh_badge:(HHBadgeView *)hh_badge {
    objc_setAssociatedObject(self, @selector(hh_badge), hh_badge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HHBadgeView *)hh_badge {
    return objc_getAssociatedObject(self, _cmd)?:({
        HHBadgeView *badgeView = [HHBadgeView badgeViewWithParentView:self];
        objc_setAssociatedObject(self, _cmd, badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        badgeView;
    });
}

@end

@implementation UIBarItem(HHAddBadge)

- (UIView*)hh_view {
    return [self valueForKeyPath:@"_view"];
}

- (UIImageView *)hh_imageView {
    return objc_getAssociatedObject(self, _cmd)?:({
        __block UIImageView *imageView = nil;
        [[self hh_view].subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                imageView = (UIImageView*)obj;
                if ([imageView.image isEqual:self.image]) {
                    objc_setAssociatedObject(self, _cmd, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    *stop = YES;
                }
            }
        }];
        imageView;
    });
}

- (UILabel *)hh_titleLabel {
    return objc_getAssociatedObject(self, _cmd)?:({
        __block UILabel *titleLabel = nil;
        [[self hh_view].subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UILabel class]]) {
                titleLabel = (UILabel*)obj;
                if ([titleLabel.text isEqualToString:self.title]) {
                    objc_setAssociatedObject(self, _cmd, titleLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    *stop = YES;
                }
            }
        }];
        titleLabel;
    });
}

@end
