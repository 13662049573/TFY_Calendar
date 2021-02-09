//
//  UIViewController+TFYCategory.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "UIViewController+TFYCategory.h"
#import <objc/runtime.h>

NSString *const TFYViewControllerPropertyChangedNotification = @"TFYViewControllerPropertyChangedNotification";

static const void* TFYInteractivePopKey      = @"TFYInteractivePopKey";
static const void* TFYFullScreenPopKey       = @"TFYFullScreenPopKey";
static const void* TFYPopMaxDistanceKey      = @"TFYPopMaxDistanceKey";
static const void* TFYPushDelegateKey        = @"TFYPushDelegateKey";
static const void* TFYPopDelegateKey         = @"TFYPopDelegateKey";
static const void* TFYPushTransitionKey      = @"TFYPushTransitionKey";
static const void* TFYPopTransitionKey       = @"TFYPopTransitionKey";
static const void* TFYNavItemLeftSpaceKey    = @"TFYNavItemLeftSpaceKey";
static const void* TFYNavItemRightSpaceKey   = @"TFYNavItemRightSpaceKey";


@implementation UIViewController (TFYCategory)

// 方法交换
+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"viewDidLoad",
                                          @"viewWillAppear:",
                                          @"viewDidAppear:"];
        
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            tfy_swizzled_method(@"tfy", self, oriSel, self);
        }];
    });
}

- (void)tfy_viewDidLoad {
    // 初始化导航栏间距
    self.tfy_navItemLeftSpace    = TFYNavigationBarItemSpace;
    self.tfy_navItemRightSpace   = TFYNavigationBarItemSpace;
    
    // 判断是否需要屏蔽导航栏间距调整
    __block BOOL exist = NO;
    [TFY_Configure.shiledItemSpaceVCs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj class] isSubclassOfClass:[UIViewController class]]) {
            if ([self isKindOfClass:[obj class]]) {
                exist = YES;
                *stop = YES;
            }
        }else if ([obj isKindOfClass:[NSString class]]) {
            if ([NSStringFromClass(self.class) isEqualToString:obj]) {
                exist = YES;
                *stop = YES;
            }
        }
    }];
    
    [TFY_Configure updateConfigure:^(TFYNavigationBarConfigure *configure) {
        configure.tfy_disableFixSpace = exist;
    }];
    
    [self tfy_viewDidLoad];
}

- (void)tfy_viewWillAppear:(BOOL)animated {
    if ([self isKindOfClass:[UINavigationController class]]) return;
    if ([self isKindOfClass:[UITabBarController class]]) return;
    if ([self isKindOfClass:[UIAlertController class]]) return;
    if ([self isKindOfClass:[UIImagePickerController class]]) return;
    if ([self isKindOfClass:[UIVideoEditorController class]]) return;
    if (!self.navigationController) return;
    
    // bug fix：#41
    if (!TFY_Configure.tfy_disableFixSpace) {
        // 每次控制器出现的时候重置导航栏间距
        if (self.tfy_navItemLeftSpace == TFYNavigationBarItemSpace) {
            self.tfy_navItemLeftSpace = TFY_Configure.navItemLeftSpace;
        }
        
        if (self.tfy_navItemRightSpace == TFYNavigationBarItemSpace) {
            self.tfy_navItemRightSpace = TFY_Configure.navItemRightSpace;
        }
        
        // 重置navitem_space
        [TFY_Configure updateConfigure:^(TFYNavigationBarConfigure *configure) {
            configure.tfy_navItemLeftSpace   = self.tfy_navItemLeftSpace;
            configure.tfy_navItemRightSpace  = self.tfy_navItemRightSpace;
        }];
    }
    
    [self tfy_viewWillAppear:animated];
}


- (void)tfy_viewDidAppear:(BOOL)animated {
    [self postPropertyChangeNotification];
    
    [self tfy_viewDidAppear:animated];
}

#pragma mark - Added Property
- (BOOL)tfy_interactivePopDisabled {
    return [objc_getAssociatedObject(self, TFYInteractivePopKey) boolValue];
}

- (void)setTfy_interactivePopDisabled:(BOOL)tfy_interactivePopDisabled {
    objc_setAssociatedObject(self, TFYInteractivePopKey, @(tfy_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (BOOL)tfy_fullScreenPopDisabled {
    return [objc_getAssociatedObject(self, TFYFullScreenPopKey) boolValue];
}

- (void)setTfy_fullScreenPopDisabled:(BOOL)tfy_fullScreenPopDisabled {
    objc_setAssociatedObject(self, TFYFullScreenPopKey, @(tfy_fullScreenPopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (CGFloat)tfy_popMaxAllowedDistanceToLeftEdge {
    return [objc_getAssociatedObject(self, TFYPopMaxDistanceKey) floatValue];
}

- (void)setTfy_popMaxAllowedDistanceToLeftEdge:(CGFloat)tfy_popMaxAllowedDistanceToLeftEdge {
    objc_setAssociatedObject(self, TFYPopMaxDistanceKey, @(tfy_popMaxAllowedDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (id<TFYViewControllerPushDelegate>)tfy_pushDelegate {
    return objc_getAssociatedObject(self, TFYPushDelegateKey);
}

- (void)setTfy_pushDelegate:(id<TFYViewControllerPushDelegate>)tfy_pushDelegate {
    objc_setAssociatedObject(self, TFYPushDelegateKey, tfy_pushDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (id<TFYViewControllerPopDelegate>)tfy_popDelegate {
    return objc_getAssociatedObject(self, TFYPopDelegateKey);
}

- (void)setTfy_popDelegate:(id<TFYViewControllerPopDelegate>)tfy_popDelegate {
    objc_setAssociatedObject(self, TFYPopDelegateKey, tfy_popDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (id<UIViewControllerAnimatedTransitioning>)tfy_pushTransition {
    return objc_getAssociatedObject(self, TFYPushTransitionKey);
}

- (void)setTfy_pushTransition:(id<UIViewControllerAnimatedTransitioning>)tfy_pushTransition {
    objc_setAssociatedObject(self, TFYPushTransitionKey, tfy_pushTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<UIViewControllerAnimatedTransitioning>)tfy_popTransition {
    return objc_getAssociatedObject(self, TFYPopTransitionKey);
}

- (void)setTfy_popTransition:(id<UIViewControllerAnimatedTransitioning>)tfy_popTransition {
    objc_setAssociatedObject(self, TFYPopTransitionKey, tfy_popTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)tfy_navItemLeftSpace {
    return [objc_getAssociatedObject(self, TFYNavItemLeftSpaceKey) floatValue];
}

- (void)setTfy_navItemLeftSpace:(CGFloat)tfy_navItemLeftSpace {
    objc_setAssociatedObject(self, TFYNavItemLeftSpaceKey, @(tfy_navItemLeftSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (tfy_navItemLeftSpace == TFYNavigationBarItemSpace) return;
    
    [TFY_Configure updateConfigure:^(TFYNavigationBarConfigure * _Nonnull configure) {
        configure.tfy_navItemLeftSpace = tfy_navItemLeftSpace;
    }];
}

- (CGFloat)tfy_navItemRightSpace {
    return [objc_getAssociatedObject(self, TFYNavItemRightSpaceKey) floatValue];
}

- (void)setTfy_navItemRightSpace:(CGFloat)tfy_navItemRightSpace {
    objc_setAssociatedObject(self, TFYNavItemRightSpaceKey, @(tfy_navItemRightSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (tfy_navItemRightSpace == TFYNavigationBarItemSpace) return;
    
    [TFY_Configure updateConfigure:^(TFYNavigationBarConfigure *configure) {
        configure.tfy_navItemRightSpace = tfy_navItemRightSpace;
    }];
}

- (UIViewController *)tfy_visibleViewControllerIfExist {
    if (self.presentedViewController) {
        return [self.presentedViewController tfy_visibleViewControllerIfExist];
    }
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).topViewController tfy_visibleViewControllerIfExist];
    }
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController tfy_visibleViewControllerIfExist];
    }
    if ([self isViewLoaded] && self.view.window) {
        return self;
    }else {
        NSLog(@"找不到可见的控制器，viewcontroller.self = %@，self.view.window=%@", self, self.view.window);
        return nil;
    }
}

- (void)postPropertyChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:TFYViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}


@end
