//
//  UIView+Badge.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/12/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_BadgeControl;

typedef NS_ENUM(NSUInteger, BadgeViewFlexMode);

#pragma mark - Protocol

@protocol BadgeView <NSObject>

@required

@property (nonatomic, strong, readonly) TFY_BadgeControl * _Nonnull badgeView;
/**
 添加带文本内容的Badge, 默认右上角, 红色, 18pts
 */
- (void)tfy_addBadgeWithText:(NSString * _Nonnull)text;
/**
 添加带数字的Badge, 默认右上角,红色,18pts
 */
- (void)tfy_addBadgeWithNumber:(NSInteger)number;
/**
 添加带颜色的小圆点, 默认右上角, 红色, 8pts
 */
- (void)tfy_addDotWithColor:(UIColor * _Nonnull)color;
/**
 设置Badge的高度,因为Badge宽度是动态可变的,通过改变Badge高度,其宽度也按比例变化,方便布局
 (注意: 此方法需要将Badge添加到控件上后再调用!!!)
 */
- (void)tfy_setBadgeHeight:(CGFloat)height;
/**
 设置Badge的偏移量, Badge中心点默认为其父视图的右上角
 */
- (void)tfy_moveBadgeWithX:(CGFloat)x Y:(CGFloat)y;
/**
 设置Badge伸缩的方向
 */
- (void)tfy_setBadgeFlexMode:(BadgeViewFlexMode)flexMode;

/// 显示Badge
- (void)tfy_showBadge;

/// 隐藏Badge
- (void)tfy_hiddenBadge;

/// 数字增加/减少, 注意:以下方法只适用于Badge内容为纯数字的情况
/// Digital increase /decrease, note: the following method applies only to cases where the Badge content is purely numeric
- (void)tfy_increase;
- (void)tfy_increaseBy:(NSInteger)number;
- (void)tfy_decrease;
- (void)tfy_decreaseBy:(NSInteger)number;

@end


NS_ASSUME_NONNULL_BEGIN

@interface UIView (Badge)<BadgeView>
@end

@interface UIView (Constraint)
- (NSLayoutConstraint *)widthConstraint;
- (NSLayoutConstraint *)heightConstraint;
- (NSLayoutConstraint *)topConstraintWithItem:(id)item;
- (NSLayoutConstraint *)leadingConstraintWithItem:(id)item;
- (NSLayoutConstraint *)bottomConstraintWithItem:(id)item;
- (NSLayoutConstraint *)trailingConstraintWithItem:(id)item;
- (NSLayoutConstraint *)centerXConstraintWithItem:(id)item;
- (NSLayoutConstraint *)centerYConstraintWithItem:(id)item;
@end

NS_ASSUME_NONNULL_END
