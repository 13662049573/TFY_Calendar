//
//  UIBarButtonItem+Badge.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/12/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIBarButtonItem+Badge.h"

@implementation UIBarButtonItem (Badge)

- (TFY_BadgeControl *)badgeView
{
    return [self bottomView].badgeView;
}

- (void)tfy_addBadgeWithText:(NSString *)text
{
    [[self bottomView] tfy_addBadgeWithText:text];
}

- (void)tfy_addBadgeWithNumber:(NSInteger)number
{
    [[self bottomView] tfy_addBadgeWithNumber:number];
}

- (void)tfy_addDotWithColor:(UIColor *)color
{
    [[self bottomView] tfy_addDotWithColor:color];
}

- (void)tfy_setBadgeHeight:(CGFloat)height
{
    [[self bottomView] tfy_setBadgeHeight:height];
}

- (void)tfy_setBadgeFlexMode:(BadgeViewFlexMode)flexMode
{
    [[self bottomView] tfy_setBadgeFlexMode:flexMode];
}

- (void)tfy_moveBadgeWithX:(CGFloat)x Y:(CGFloat)y
{
    [[self bottomView] tfy_moveBadgeWithX:x Y:y];
}

- (void)tfy_showBadge
{
    [[self bottomView] tfy_showBadge];
}

- (void)tfy_hiddenBadge
{
    [[self bottomView] tfy_hiddenBadge];
}

- (void)tfy_increase
{
    [[self bottomView] tfy_increase];
}

- (void)tfy_increaseBy:(NSInteger)number
{
    [[self bottomView] tfy_increaseBy:number];
}

- (void)tfy_decrease
{
    [[self bottomView] tfy_decrease];
}

- (void)tfy_decreaseBy:(NSInteger)number
{
    [[self bottomView] tfy_decreaseBy:number];
}

#pragma mark - 获取Badge的父视图
- (UIView *)bottomView
{
    // 通过Xcode视图调试工具找到UIBarButtonItem的Badge所在父视图为:UIImageView
    UIView *navigationButton = [self valueForKey:@"_view"];
    double systemVersion = [UIDevice currentDevice].systemVersion.doubleValue;
    NSString *controlName = (systemVersion < 11 ? @"UIImageView" : @"UIButton" );
    for (UIView *subView in navigationButton.subviews) {
        if ([subView isKindOfClass:NSClassFromString(controlName)]) {
            subView.layer.masksToBounds = NO;
            return subView;
        }
    }
    return navigationButton;
}

@end
