//
//  UINavigationItem+TFYCategory.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "UINavigationItem+TFYCategory.h"
#import <objc/runtime.h>
#import "TFYCommon.h"

@implementation UINavigationItem (TFYCategory)
+ (void)load {
    if (@available(iOS 11.0, *)) {} else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSArray <NSString *>*oriSels = @[@"setLeftBarButtonItem:",
                                             @"setLeftBarButtonItem:animated:",
                                             @"setLeftBarButtonItems:",
                                             @"setLeftBarButtonItems:animated:",
                                             @"setRightBarButtonItem:",
                                             @"setRightBarButtonItem:animated:",
                                             @"setRightBarButtonItems:",
                                             @"setRightBarButtonItems:animated:"];
            
            [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
                tfy_swizzled_method(@"tfy", self, oriSel, self);
            }];
        });
    }
}

- (void)tfy_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

- (void)tfy_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem animated:(BOOL)animated {
    if (!TFY_Configure.tfy_disableFixSpace && leftBarButtonItem) {//存在按钮且需要调节
        [self setLeftBarButtonItems:@[leftBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self setLeftBarButtonItems:nil];
        [self tfy_setLeftBarButtonItem:leftBarButtonItem animated:animated];
    }
}

- (void)tfy_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    [self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

- (void)tfy_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems animated:(BOOL)animated {
    if (!TFY_Configure.tfy_disableFixSpace && leftBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = leftBarButtonItems.firstObject;
        CGFloat width = TFY_Configure.tfy_navItemLeftSpace - TFY_Configure.tfy_fixedSpace;
        if (firstItem.width == width) {//已经存在space
            [self tfy_setLeftBarButtonItems:leftBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:leftBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self tfy_setLeftBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self tfy_setLeftBarButtonItems:leftBarButtonItems animated:animated];
    }
}

- (void)tfy_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    [self setRightBarButtonItem:rightBarButtonItem animated:NO];
}

- (void)tfy_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem animated:(BOOL)animated {
    if (!TFY_Configure.tfy_disableFixSpace && rightBarButtonItem) {//存在按钮且需要调节
        [self setRightBarButtonItems:@[rightBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self setRightBarButtonItems:nil];
        [self tfy_setRightBarButtonItem:rightBarButtonItem animated:animated];
    }
}

- (void)tfy_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    [self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (void)tfy_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems animated:(BOOL)animated {
    if (!TFY_Configure.tfy_disableFixSpace && rightBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = rightBarButtonItems.firstObject;
        CGFloat width = TFY_Configure.tfy_navItemRightSpace - TFY_Configure.tfy_fixedSpace;
        if (firstItem.width == width) {//已经存在space
            [self tfy_setRightBarButtonItems:rightBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:rightBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self tfy_setRightBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self tfy_setRightBarButtonItems:rightBarButtonItems animated:animated];
    }
}

- (UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end


@interface NSObject (GKCategory)
@end

@implementation NSObject (GKCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            NSDictionary *oriSels = @{@"_UINavigationBarContentView": @"layoutSubviews",
                                      @"_UINavigationBarContentViewLayout": @"_updateMarginConstraints"
                                    };
            // bug fixed：这里要用NSObject.class 不能用self，不然会导致crash
            // 具体可看 注意系统库的坑之load函数调用多次 http://satanwoo.github.io/2017/11/02/load-twice/
            [oriSels enumerateKeysAndObjectsUsingBlock:^(NSString *cls, NSString *oriSel, BOOL * _Nonnull stop) {
                tfy_swizzled_method(@"tfy", NSClassFromString(cls), oriSel, NSObject.class);
            }];
        }
    });
}

- (void)tfy_layoutSubviews {
    if (TFY_Configure.tfy_disableFixSpace) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentView")]) return;
    id layout = [self valueForKey:@"_layout"];
    if (!layout) return;
    SEL selector = NSSelectorFromString(@"_updateMarginConstraints");
    IMP imp = [layout methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(layout, selector);
    [self tfy_layoutSubviews];
}

- (void)tfy__updateMarginConstraints {
    if (TFY_Configure.tfy_disableFixSpace) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentViewLayout")]) return;
    [self tfy_adjustLeadingBarConstraints];
    [self tfy_adjustTrailingBarConstraints];
    [self tfy__updateMarginConstraints];
}

- (void)tfy_adjustLeadingBarConstraints {
    if (TFY_Configure.tfy_disableFixSpace) return;
    NSArray<NSLayoutConstraint *> *leadingBarConstraints = [self valueForKey:@"_leadingBarConstraints"];
    if (!leadingBarConstraints) return;
    CGFloat constant = TFY_Configure.tfy_navItemLeftSpace - TFY_Configure.tfy_fixedSpace;
    for (NSLayoutConstraint *constraint in leadingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeLeading && constraint.secondAttribute == NSLayoutAttributeLeading) {
            constraint.constant = constant;
        }
    }
}

- (void)tfy_adjustTrailingBarConstraints {
    if (TFY_Configure.tfy_disableFixSpace) return;
    NSArray<NSLayoutConstraint *> *trailingBarConstraints = [self valueForKey:@"_trailingBarConstraints"];
    if (!trailingBarConstraints) return;
    CGFloat constant = TFY_Configure.tfy_fixedSpace - TFY_Configure.tfy_navItemRightSpace;
    for (NSLayoutConstraint *constraint in trailingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeTrailing && constraint.secondAttribute == NSLayoutAttributeTrailing) {
            constraint.constant = constant;
        }
    }
}

@end

