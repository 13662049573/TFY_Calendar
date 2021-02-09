//
//  UIView+Badge.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/12/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIView+Badge.h"
#import "TFY_BadgeControl.h"
#import <objc/runtime.h>

static NSString *const kBadgeView = @"kBadgeView";

@interface UIView ()
@end

@implementation UIView (Badge)

- (void)tfy_addBadgeWithText:(NSString * _Nonnull)text
{
    [self tfy_showBadge];
    self.badgeView.text = text;
    [self tfy_setBadgeFlexMode:self.badgeView.flexMode];
    if (![self emptyWithString:text]) {
        if (self.badgeView.widthConstraint && self.badgeView.widthConstraint.relation == NSLayoutRelationGreaterThanOrEqual) { return; }
        self.badgeView.widthConstraint.active = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.badgeView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        [self.badgeView addConstraint:constraint];
    } else {
        if (self.badgeView.widthConstraint && self.badgeView.widthConstraint.relation == NSLayoutRelationEqual) { return; }
        self.badgeView.widthConstraint.active = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.badgeView attribute:(NSLayoutAttributeHeight) multiplier:1.0 constant:0];
        [self.badgeView addConstraint:constraint];
    }
}

- (BOOL)emptyWithString:(NSString *)string {
    if (string.length == 0 || [string isEqualToString:@""] || string == nil || string == NULL || [string isEqual:[NSNull null]] || [string isEqualToString:@" "] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}

- (void)tfy_addBadgeWithNumber:(NSInteger)number
{
    if (number <= 0) {
        [self tfy_addBadgeWithText:@"0"];
        [self tfy_hiddenBadge];
        return;
    }
    [self tfy_addBadgeWithText:[NSString stringWithFormat:@"%ld",number]];
}

- (void)tfy_addDotWithColor:(UIColor *)color
{
    [self tfy_addBadgeWithText:@""];
    [self tfy_setBadgeHeight:8.0];
    self.badgeView.backgroundColor = color;
}

- (void)tfy_moveBadgeWithX:(CGFloat)x Y:(CGFloat)y
{
    self.badgeView.offset = CGPointMake(x, y);
    [self centerYConstraintWithItem:self.badgeView].constant = y;
    
    CGFloat badgeHeight = self.badgeView.heightConstraint.constant;
    switch (self.badgeView.flexMode) {
        case BadgeViewFlexModeHead: // 1. 左伸缩  <==●
        {
            [self centerXConstraintWithItem:self.badgeView].active = NO;
            [self leadingConstraintWithItem:self.badgeView].active = NO;
            if ([self trailingConstraintWithItem:self.badgeView]) {
                [self trailingConstraintWithItem:self.badgeView].constant = x + badgeHeight*0.5;
                return;
            }
            NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeTrailing relatedBy:(NSLayoutRelationEqual) toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:(x + badgeHeight*0.5)];
            [self addConstraint:trailingConstraint];
            break;
        }
        case BadgeViewFlexModeTail: // 2. 右伸缩 ●==>
        {
            [self centerXConstraintWithItem:self.badgeView].active = NO;
            [self trailingConstraintWithItem:self.badgeView].active = NO;
            if ([self leadingConstraintWithItem:self.badgeView]) {
                [self leadingConstraintWithItem:self.badgeView].constant = x - badgeHeight*0.5;
                return;
            }
            NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:(x - badgeHeight*0.5)];
            [self addConstraint:leadingConstraint];
            break;
        }
        case BadgeViewFlexModeMiddle: // 3. 左右伸缩  <=●=>
        {
            [self leadingConstraintWithItem:self.badgeView].active = NO;
            [self trailingConstraintWithItem:self.badgeView].active = NO;
            if ([self centerXConstraintWithItem:self.badgeView]) {
                [self centerXConstraintWithItem:self.badgeView].constant = x;
                return;
            }
            NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:x];
            [self addConstraint:centerXConstraint];
            break;
        }
    }
}

- (void)tfy_setBadgeFlexMode:(BadgeViewFlexMode)flexMode
{
    self.badgeView.flexMode = flexMode;
    [self tfy_moveBadgeWithX:self.badgeView.offset.x Y:self.badgeView.offset.y];
}

- (void)tfy_setBadgeHeight:(CGFloat)height
{
    self.badgeView.layer.cornerRadius = height * 0.5;
    self.badgeView.heightConstraint.constant = height;
    [self tfy_moveBadgeWithX:self.badgeView.offset.x Y:self.badgeView.offset.y];
}

- (void)tfy_showBadge
{
    self.badgeView.hidden = NO;
}

- (void)tfy_hiddenBadge
{
    self.badgeView.hidden = YES;
}

- (void)tfy_increase
{
    [self tfy_increaseBy:1];
}

- (void)tfy_increaseBy:(NSInteger)number
{
    NSInteger result = self.badgeView.text.integerValue + number;
    if (result > 0) {
        [self tfy_showBadge];
    }
    self.badgeView.text = [NSString stringWithFormat:@"%ld",result];
}

- (void)tfy_decrease
{
    [self tfy_decreaseBy:1];
}

- (void)tfy_decreaseBy:(NSInteger)number
{
    NSInteger result = self.badgeView.text.integerValue - number;
    if (result <= 0) {
        [self tfy_hiddenBadge];
        self.badgeView.text = @"0";
        return;
    }
    self.badgeView.text = [NSString stringWithFormat:@"%ld",result];
}

- (void)addBadgeViewLayoutConstraint
{
    [self.badgeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.badgeView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.badgeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:14];
    [self addConstraints:@[centerXConstraint, centerYConstraint]];
    [self.badgeView addConstraints:@[widthConstraint, heightConstraint]];
}

#pragma mark - setter/getter

- (TFY_BadgeControl *)badgeView
{
    TFY_BadgeControl *badgeView = objc_getAssociatedObject(self, &kBadgeView);
    if (!badgeView) {
        badgeView = [TFY_BadgeControl defaultBadge];
        [self addSubview:badgeView];
        [self bringSubviewToFront:badgeView];
        [self setBadgeView:badgeView];
        [self addBadgeViewLayoutConstraint];
    }
    return badgeView;
}

- (void)setBadgeView:(TFY_BadgeControl *)badgeView
{
    objc_setAssociatedObject(self, &kBadgeView, badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIView (Constraint)

- (NSLayoutConstraint *)widthConstraint
{
    return [self constraint:self attribute:NSLayoutAttributeWidth];
}

- (NSLayoutConstraint *)heightConstraint
{
    return [self constraint:self attribute:NSLayoutAttributeHeight];
}

- (NSLayoutConstraint *)topConstraintWithItem: (id)item
{
    return [self constraint:item attribute:NSLayoutAttributeTop];
}

- (NSLayoutConstraint *)leadingConstraintWithItem: (id)item
{
    return [self constraint:item attribute:NSLayoutAttributeLeading];
}

- (NSLayoutConstraint *)bottomConstraintWithItem:(id)item
{
    return [self constraint:item attribute:NSLayoutAttributeBottom];
}

- (NSLayoutConstraint *)trailingConstraintWithItem:(id)item
{
    return [self constraint:item attribute:NSLayoutAttributeTrailing];
}

- (NSLayoutConstraint *)centerXConstraintWithItem:(id)item
{
    return [self constraint:item attribute:NSLayoutAttributeCenterX];
}

- (NSLayoutConstraint *)centerYConstraintWithItem:(id)item
{
    return [self constraint:item attribute:NSLayoutAttributeCenterY];
}

- (NSLayoutConstraint *)constraint:(id)item attribute: (NSLayoutAttribute)layoutAttribute
{
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstItem == item && constraint.firstAttribute == layoutAttribute) {
            return constraint;
        }
    }
    return nil;
}

@end
