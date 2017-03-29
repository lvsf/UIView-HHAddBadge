//
//  UIView+HHAddBadge.m
//  UIView+HHAddBadge
//
//  Created by YunSL on 17/3/10.
//  Copyright © 2017年 YunSL. All rights reserved.
//

#import "UIView+HHAddBadge.h"
#import <objc/runtime.h>

#define HHViewBadgeLayoutDefaultOrigin CGPointMake(-1, -1)
#define HHViewBadgeLayoutDefaultSize CGSizeMake(-1, -1)
#define HHViewBadgeLayoutDefaultDotSize CGSizeMake(6, 6)

static inline CGRect HHBadgeTextBound(NSString *text, UIFont *font) {
    return [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                              options:NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName:font}
                              context:nil];

};

#pragma mark - HHBadgeDisplayRule
@interface HHBadgeDisplayRule()
@property (nonatomic,strong) NSMutableDictionary *badgeDisplayHeightMap;
@end

@implementation HHBadgeDisplayRule

- (CGRect)badgeDisplayContainer:(UIView *)displayContainer adjustWithFrame:(CGRect)displayContainerFrame andBadgeType:(HHBadgeType)badgeType andApperence:(HHBadgeApperence *)apperence {
    CGRect adjustFrame = displayContainerFrame;
    CGFloat boardWidth = 1.5;
    if (badgeType == HHBadgeTypeNumber ||
        badgeType == HHBadgeTypeText) {
        adjustFrame.size.width += apperence.font.lineHeight * 0.3 + 2 * boardWidth;
        if (CGRectGetWidth(adjustFrame) < CGRectGetHeight(adjustFrame)) {
            adjustFrame.size.width = CGRectGetHeight(adjustFrame);
        }
    }
    if (badgeType == HHBadgeTypeNumber ||
        badgeType == HHBadgeTypeText ||
        badgeType == HHBadgeTypeDot)
    {
        CGFloat lastHeight = -1;
        CGFloat currentHeight = CGRectGetHeight(displayContainerFrame);
        NSString *lastHeightKey = [@(badgeType) stringValue];
        if ([self.badgeDisplayHeightMap.allKeys containsObject:lastHeightKey]) {
            lastHeight = [self.badgeDisplayHeightMap[lastHeightKey] doubleValue];
        }
        if (lastHeight == -1 || (lastHeight >= 0 && fabs(lastHeight - currentHeight) >= 0.1)) {
            displayContainer.layer.masksToBounds = YES;
            displayContainer.layer.cornerRadius = currentHeight * 0.5;
        }
        [self.badgeDisplayHeightMap setObject:@(currentHeight) forKey:lastHeightKey];
    }
    else
    {
        displayContainer.layer.masksToBounds = NO;
        displayContainer.layer.cornerRadius = 0;
    }
    return adjustFrame;
}

- (NSMutableDictionary *)badgeDisplayHeightMap {
    return _badgeDisplayHeightMap?:({
        _badgeDisplayHeightMap = [NSMutableDictionary new];
        _badgeDisplayHeightMap;
    });
}

@end

#pragma mark - HHBadgeApperence
@implementation HHBadgeApperence
@synthesize defaultDisplayRule = _defaultDisplayRule;

- (id)copyWithZone:(NSZone *)zone {
    HHBadgeApperence *apperence = [self.class new];
    apperence.font = self.font;
    apperence.anchorPoint = self.anchorPoint;
    apperence.horizontalPosition = self.horizontalPosition;
    apperence.verticalPosition = self.verticalPosition;
    apperence.centerOffsetInsets = self.centerOffsetInsets;
    apperence.contentInsets = self.contentInsets;
    apperence.origin = self.origin;
    apperence.size = self.size;
    apperence.tintColor = self.tintColor;
    apperence.backgroudColor = self.backgroudColor;
    apperence.backgroudImage = self.backgroudImage;
    apperence.displayRule = self.defaultDisplayRule;
    return apperence;
}

- (void)reset {
    self.displayRule = self.defaultDisplayRule;
    self.origin = HHViewBadgeLayoutDefaultOrigin;
    self.size = HHViewBadgeLayoutDefaultSize;
    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.font = [UIFont systemFontOfSize:15];
    self.backgroudColor = [UIColor redColor];
    self.backgroudImage = nil;
    self.tintColor = [UIColor whiteColor];
    self.contentInsets = UIEdgeInsetsZero;
    self.centerOffsetInsets = UIEdgeInsetsZero;
    self.horizontalPosition = HHBadgePositionFooter;
    self.verticalPosition = HHBadgePositionHeader;
}

- (HHBadgeDisplayRule *)defaultDisplayRule {
    return _defaultDisplayRule?:({
        _defaultDisplayRule = [HHBadgeDisplayRule new];
        _defaultDisplayRule;
    });
}

@end

#pragma mark - HHBadgeManager
@interface HHBadgeManager : NSObject
@property (nonatomic,assign) CGRect badgeTargetFrame;
@property (nonatomic,strong) id badgeValue;
@property (nonatomic,strong,readonly) HHBadgeApperence *badgeApperence;
@property (nonatomic,assign,readonly) HHBadgeType badgeType;
@property (nonatomic,assign,readonly) CGRect badgeFrame;
@property (nonatomic,assign,readonly) CGRect badgeDipslayContainerFrame;
@property (nonatomic,strong,readonly) UIImageView *badgeDipslayContainer;
@property (nonatomic,strong,readonly) UILabel *badgeLabel;
@property (nonatomic,strong,readonly) UILabel *badgeNumberLabel;
@property (nonatomic,strong,readonly) UIView *badgeColorView;
@property (nonatomic,strong,readonly) UIImageView *badgeImageView;
@property (nonatomic,strong,readonly) UIView *badgeView;
@property (nonatomic,assign,readonly) BOOL badgeNeedLayout;
- (void)updateLayout;
- (void)updateLayoutIfNeed;
- (void)updateBadgeValue;
- (void)updateApperence;
@end

@implementation HHBadgeManager
@synthesize badgeType = _badgeType;
@synthesize badgeFrame = _badgeFrame;
@synthesize badgeDipslayContainerFrame = _badgeDipslayContainerFrame;
@synthesize badgeDipslayContainer = _badgeDipslayContainer;
@synthesize badgeNumberLabel = _badgeNumberLabel;
@synthesize badgeLabel = _badgeLabel;
@synthesize badgeColorView = _badgeColorView;
@synthesize badgeImageView = _badgeImageView;
@synthesize badgeView = _badgeView;
@synthesize badgeApperence = _badgeApperence;

+ (NSArray*)observeLayoutKeyPaths {
    return @[@"font",@"anchorPoint",@"horizontalPosition",
             @"verticalPosition",@"centerOffsetInsets",
             @"origin",@"size"];
}

- (void)dealloc {
    [[self.class observeLayoutKeyPaths] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.badgeApperence removeObserver:self forKeyPath:obj];
    }];
    [self removeObserver:self forKeyPath:@"badgeValue"];
    [self removeObserver:self forKeyPath:@"badgeTargetFrame"];
}

- (instancetype)init {
    if (self = [super init]) {
        [self addObserver:self
               forKeyPath:@"badgeValue"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        [self addObserver:self
               forKeyPath:@"badgeTargetFrame"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        [[self.class observeLayoutKeyPaths] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.badgeApperence addObserver:self
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
            _badgeNeedLayout = YES;
        }
        if ([NSStringFromClass([newValue class]) isEqualToString:NSStringFromClass([oldValue class])]) {
            //NSNumer
            if ([newValue isKindOfClass:[NSValue class]]) {
                if (![newValue isEqualToValue:oldValue]) {
                    _badgeNeedLayout = YES;
                }
            }
            //UIFont
            if ([newValue isKindOfClass:[UIFont class]]) {
            }
        }
    }
}

- (void)updateBadgeValue {
    _badgeView = nil;
    _badgeType = HHBadgeTypeNot;
    id badgeValue = self.badgeValue;
    //1.数字类型
    if ([badgeValue isKindOfClass:[NSNumber class]]) {
        [self.badgeNumberLabel setText:[badgeValue stringValue]];
        _badgeView = self.badgeNumberLabel;
        _badgeType = HHBadgeTypeNumber;
    }
    //2.文本类型
    if ([badgeValue isKindOfClass:[NSString class]]) {
        [self.badgeLabel setText:badgeValue];
        _badgeView = self.badgeLabel;
        _badgeType = HHBadgeTypeText;
    }
    //3.图片类型
    if ([badgeValue isKindOfClass:[UIImage class]]) {
        [self.badgeImageView setImage:badgeValue];
        _badgeView = self.badgeImageView;
        _badgeType = HHBadgeTypeImage;
    }
    //5.颜色类型
    if ([badgeValue isKindOfClass:[UIColor class]]) {
        [self.badgeColorView setBackgroundColor:badgeValue];
        _badgeView = self.badgeColorView;
        _badgeType = HHBadgeTypeDot;
    }
    //6.视图类型
    if ([badgeValue isKindOfClass:[UIView class]]) {
        _badgeView = badgeValue;
        _badgeType = HHBadgeTypeCustomView;
    }
}

- (void)updateLayoutIfNeed {
    if (_badgeNeedLayout) {
        [self updateLayout];
        _badgeNeedLayout = NO;
    }
}

- (void)updateLayout {;
    CGRect containerFrame = CGRectZero;
    CGRect targetFrame = self.badgeTargetFrame;
    if (CGRectGetWidth(targetFrame) > 0 && CGRectGetHeight(targetFrame) > 0) {
        if (!CGSizeEqualToSize(self.badgeApperence.size, HHViewBadgeLayoutDefaultSize)) {
            containerFrame.size = self.badgeApperence.size;
        } else {
            CGRect badgeFrame = CGRectZero;
            switch (self.badgeType) {
                case HHBadgeTypeNumber:
                    badgeFrame.size = HHBadgeTextBound(self.badgeNumberLabel.text, self.badgeNumberLabel.font).size;
                    break;
                case HHBadgeTypeText:
                    badgeFrame.size = HHBadgeTextBound(self.badgeLabel.text, self.badgeLabel.font).size;
                    break;
                case HHBadgeTypeImage:
                    badgeFrame.size = self.badgeImageView.image.size;
                    break;
                case HHBadgeTypeDot:
                    badgeFrame.size = HHViewBadgeLayoutDefaultDotSize;
                    break;
                case HHBadgeTypeCustomView:
                    badgeFrame.size = self.badgeView.bounds.size;
                    break;
                default:
                    break;
            }
            containerFrame.size = CGSizeMake(CGRectGetWidth(badgeFrame) + self.badgeApperence.contentInsets.left + self.badgeApperence.contentInsets.right, CGRectGetHeight(badgeFrame) + self.badgeApperence.contentInsets.top + self.badgeApperence.contentInsets.bottom);
        }
        if (!CGPointEqualToPoint(self.badgeApperence.origin, HHViewBadgeLayoutDefaultOrigin)) {
            containerFrame.origin = self.badgeApperence.origin;
        } else {
            CGFloat containX = 0;
            CGFloat containY = 0;
            switch (self.badgeApperence.horizontalPosition)
            {
                case HHBadgePositionHeader:containX = 0;break;
                case HHBadgePositionCenter:containX = CGRectGetWidth(targetFrame) * 0.5;break;
                case HHBadgePositionFooter:containX = CGRectGetWidth(targetFrame);break;
                default:break;
            }
            switch (self.badgeApperence.verticalPosition)
            {
                case HHBadgePositionHeader:containY = 0;break;
                case HHBadgePositionCenter:containY = CGRectGetHeight(targetFrame) * 0.5;break;
                case HHBadgePositionFooter:containY = CGRectGetHeight(targetFrame);break;
                default:break;
            }
            CGFloat anchorPointX = MIN(1,MAX(0, self.badgeApperence.anchorPoint.x));
            CGFloat anchorPointY = MIN(1,MAX(0, self.badgeApperence.anchorPoint.y));
            containX = containX - anchorPointX * CGRectGetWidth(containerFrame);
            containX = containX + self.badgeApperence.centerOffsetInsets.left - self.badgeApperence.centerOffsetInsets.right;
            containY = containY - anchorPointY * CGRectGetHeight(containerFrame);
            containY = containY + self.badgeApperence.centerOffsetInsets.top - self.badgeApperence.centerOffsetInsets.bottom;
            containerFrame.origin = CGPointMake(containX, containY);
        }
    }
    _badgeDipslayContainerFrame = containerFrame;
    if ([self.badgeApperence.displayRule respondsToSelector:@selector(badgeDisplayContainer:adjustWithFrame:andBadgeType:andApperence:)] && CGRectGetWidth(_badgeDipslayContainerFrame) > 0 && CGRectGetHeight(_badgeDipslayContainerFrame) ) {
        _badgeDipslayContainerFrame = [self.badgeApperence.displayRule badgeDisplayContainer:self.badgeDipslayContainer
                                                                             adjustWithFrame:_badgeDipslayContainerFrame
                                                                                andBadgeType:_badgeType
                                                                                andApperence:_badgeApperence];
    }
    if (self.badgeType == HHBadgeTypeDot) {
        _badgeFrame = (CGRect){CGPointZero,_badgeDipslayContainerFrame.size};
    } else {
        _badgeFrame.origin = CGPointMake(self.badgeApperence.contentInsets.left, self.badgeApperence.contentInsets.bottom);
        _badgeFrame.size = CGSizeMake(CGRectGetWidth(_badgeDipslayContainerFrame) - self.badgeApperence.contentInsets.left - self.badgeApperence.contentInsets.right, CGRectGetHeight(_badgeDipslayContainerFrame) - self.badgeApperence.contentInsets.top - self.badgeApperence.contentInsets.bottom);
    }
}

- (void)updateApperence {
    [self handleUpdateBadgeView:self.badgeView
                      badgeType:self.badgeType
                      apperence:self.badgeApperence];
    [self handleUpdateDisplayContainerApperence];
}

- (void)handleUpdateDisplayContainerApperence {
    [self.badgeDipslayContainer setImage:self.badgeApperence.backgroudImage];
    [self.badgeDipslayContainer setBackgroundColor:self.badgeApperence.backgroudColor];
}

- (void)handleUpdateBadgeView:(UIView*)badgeView badgeType:(HHBadgeType)type apperence:(HHBadgeApperence*)apperence {
    if (type != HHBadgeTypeNot) {
        if (type != HHBadgeTypeCustomView) {
            badgeView.backgroundColor = [UIColor clearColor];
            switch (type) {
                case HHBadgeTypeText:
                case HHBadgeTypeNumber:
                {
                    UILabel *label = (UILabel*)badgeView;
                    label.font = apperence.font;
                    label.textColor = apperence.tintColor;
                    label.textAlignment = NSTextAlignmentCenter;
                }
                    break;
                case HHBadgeTypeImage:
                {
                    UIImageView *imageView = (UIImageView*)badgeView;
                    imageView.backgroundColor = [UIColor clearColor];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

- (UIView *)badgeColorView {
    return _badgeColorView?:({
        _badgeColorView = [UIView new];
        [self handleUpdateBadgeView:_badgeColorView
                          badgeType:HHBadgeTypeDot
                          apperence:self.badgeApperence];
        _badgeColorView;
    });
}

- (UILabel *)badgeNumberLabel {
    return _badgeNumberLabel?:({
        _badgeNumberLabel = [UILabel new];
        [self handleUpdateBadgeView:_badgeNumberLabel
                          badgeType:HHBadgeTypeNumber
                          apperence:self.badgeApperence];
        _badgeNumberLabel;
    });
}

- (UILabel *)badgeLabel {
    return _badgeLabel?:({
        _badgeLabel = [UILabel new];
        [self handleUpdateBadgeView:_badgeLabel
                          badgeType:HHBadgeTypeText
                          apperence:self.badgeApperence];
        _badgeLabel;
    });
}

- (UIImageView *)badgeDipslayContainer {
    return _badgeDipslayContainer?:({
        _badgeDipslayContainer = [UIImageView new];
        _badgeDipslayContainer.layer.shouldRasterize = YES;
        _badgeDipslayContainer.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _badgeDipslayContainer.contentMode = UIViewContentModeScaleAspectFit;
        [self handleUpdateDisplayContainerApperence];
        _badgeDipslayContainer;
    });
}

- (HHBadgeApperence *)badgeApperence {
    return _badgeApperence?:({
        _badgeApperence = [[UIView hh_badgeApperence] copy];
        _badgeApperence;
    });
}

@end

#pragma mark - HHAddBadge
@interface UIView()
@property (nonatomic,strong) HHBadgeManager *badgeManager;
@end

@implementation UIView (HHAddBadge)

#pragma mark - life
+ (void)load {
    SEL originalSEL = @selector(setFrame:);
    SEL newSEL = @selector(hh_setFrame:);
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

+ (HHBadgeApperence *)hh_badgeApperence {
    static HHBadgeApperence *apperence = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apperence = [HHBadgeApperence new];
        [apperence reset];
    });
    return apperence;
}

- (void)hh_remove {
    [self.badgeManager.badgeDipslayContainer removeFromSuperview];
    if (objc_getAssociatedObject(self, @selector(setBadgeManager:))) {
        self.badgeManager = nil;
    }
}

- (void)hh_updateBadgeValue:(id)badgeValue apperence:(void (^)(HHBadgeApperence *))apperenceBlock {
    if (apperenceBlock) {
        apperenceBlock(self.badgeManager.badgeApperence);
        [self.badgeManager updateApperence];
    }
    [self hh_updateBadgeValue:badgeValue];
}

- (void)hh_updateBadgeValue:(id)badgeValue {
    [self setHh_badgeValue:badgeValue];
}

- (void)hh_updateApperence:(void (^)(HHBadgeApperence *))apperenceBlock {
    if (apperenceBlock) {
        apperenceBlock(self.badgeManager.badgeApperence);
        [self.badgeManager updateApperence];
        [self handleUpdateLayout];
    }
}

- (void)hh_setFrame:(CGRect)frame {
    [self hh_setFrame:frame];
    if (self.hh_badgeView) {
        [self handleUpdateLayout];
    }
}

#pragma mark - private
- (void)handleUpdateLayout {
    [self.badgeManager setBadgeTargetFrame:self.frame];
    [self.badgeManager updateLayoutIfNeed];
    [self.hh_badgeView setFrame:self.badgeManager.badgeFrame];
    [self.badgeManager.badgeDipslayContainer setFrame:({
        CGRect containerFrame = self.badgeManager.badgeDipslayContainerFrame;
        if ([self.superview isEqual:self.badgeManager.badgeDipslayContainer.superview]) {
            containerFrame = [self.superview convertRect:containerFrame fromView:self];
        }
        containerFrame;
    })];
}

- (void)handleUpdateBadgeValue {
    if (self.hh_badgeValue)
    {
        if (!self.badgeManager.badgeDipslayContainer.superview) {
            UIView *container = self;
            if (container.superview) {
                container = container.superview;
            }
            [container addSubview:self.badgeManager.badgeDipslayContainer];
        }
        [self.hh_badgeView removeFromSuperview];
        [self.badgeManager setBadgeValue:self.hh_badgeValue];
        [self.badgeManager updateBadgeValue];
        [self setHh_badgeView:self.badgeManager.badgeView];
        [self.badgeManager.badgeDipslayContainer addSubview:self.hh_badgeView];
        [self handleUpdateLayout];
    }
    else
    {
        [self hh_remove];
    }
}

#pragma mark - set/get
- (void)setHh_badgeValue:(id)hh_badgeValue {
    objc_setAssociatedObject(self, @selector(hh_badgeValue), hh_badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self handleUpdateBadgeValue];
}

- (void)setHh_badgeView:(UIView *)hh_badgeView {
    objc_setAssociatedObject(self, @selector(hh_badgeView), hh_badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)hh_badgeValue {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIView *)hh_badgeView {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGRect)hh_badgeViewFrame {
    return self.badgeManager.badgeFrame;
}

- (CGRect)hh_badgeDisplayContainerFrame {
    return self.badgeManager.badgeDipslayContainerFrame;
}

- (HHBadgeManager *)badgeManager {
    return objc_getAssociatedObject(self, _cmd)?:({
        HHBadgeManager *manager = [HHBadgeManager new];
        objc_setAssociatedObject(self, _cmd, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        manager;
    });
}

@end
