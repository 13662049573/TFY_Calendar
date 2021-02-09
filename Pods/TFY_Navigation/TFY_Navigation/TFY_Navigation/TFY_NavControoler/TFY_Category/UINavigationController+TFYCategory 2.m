//
//  UINavigationController+TFYCategory.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "UINavigationController+TFYCategory.h"
#include <objc/runtime.h>

@implementation UINavigationController (TFYCategory)

// 方法交换
+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tfy_swizzled_method(@"tfyNav", self, @"viewDidLoad", self);
    });
}

- (void)tfyNav_viewDidLoad {
    // 处理特殊控制器
    if ([self isKindOfClass:[UIImagePickerController class]]) return;
    if ([self isKindOfClass:[UIVideoEditorController class]]) return;
    
    // 设置代理和通知
    // 设置背景色
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置代理
    self.delegate = self.navDelegate;
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:TFYViewControllerPropertyChangedNotification object:nil];
    
    [self tfyNav_viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TFYViewControllerPropertyChangedNotification object:nil];
}

#pragma mark - Notification Handle
- (void)handleNotification:(NSNotification *)notify {
    // 获取通知传递的控制器
    UIViewController *vc = (UIViewController *)notify.object[@"viewController"];
    
    // 不处理导航控制器和tabbar控制器
    if ([vc isKindOfClass:[UINavigationController class]]) return;
    if ([vc isKindOfClass:[UITabBarController class]]) return;
    if (!vc.navigationController) return;
    if (vc.navigationController != self) return;
    
    __block BOOL exist = NO;
    [TFY_Configure.shiledGuestureVCs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj class] isSubclassOfClass:[UIViewController class]]) {
            if ([vc isKindOfClass:[obj class]]) {
                exist = YES;
                *stop = YES;
            }
        }else if ([obj isKindOfClass:[NSString class]]) {
            if ([NSStringFromClass(vc.class) isEqualToString:obj]) {
                exist = YES;
                *stop = YES;
            }
        }
    }];
    if (exist) return;
    
    // 禁止手势处理
    if (self.tfy_disabledGestureHandle) {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.screenPanGesture];
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.panGesture];
        return;
    }
    
    BOOL isRootVC = vc == self.viewControllers.firstObject;
    
    // 重新根据属性添加手势方法
    if (vc.tfy_interactivePopDisabled) { // 禁止滑动
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.screenPanGesture];
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.panGesture];
    }else if (vc.tfy_fullScreenPopDisabled) { // 禁止全屏滑动
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.panGesture];
        
        if (self.tfy_translationScale) {
            self.interactivePopGestureRecognizer.delegate = nil;
            self.interactivePopGestureRecognizer.enabled = NO;
            
            if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.screenPanGesture]) {
                [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.screenPanGesture];
                self.screenPanGesture.delegate = self.popGestureDelegate;
            }
        }else {
            self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
            self.interactivePopGestureRecognizer.delegate = self.popGestureDelegate;
            self.interactivePopGestureRecognizer.enabled = !isRootVC;
        }
    }else {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.screenPanGesture];
        
        // 给self.interactivePopGestureRecognizer.view 添加全屏滑动手势
        if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.panGesture]) {
            [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.panGesture];
            self.panGesture.delegate = self.popGestureDelegate;
        }
        
        // 添加手势处理
        if (self.tfy_translationScale || self.tfy_openScrollLeftPush || self.visibleViewController.tfy_popDelegate) {
            [self.panGesture addTarget:self.navDelegate action:@selector(panGestureRecognizerAction:)];
        }else {
            SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
            [self.panGesture addTarget:[self systemTarget] action:internalAction];
        }
    }
}

- (void)tfy_navigationBarTransparent {
    //设置导航栏背景图片为一个空的image，这样就透明了
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.navigationBar.translucent = YES;
}

- (void)tfy_navigationBarOpaque {
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:nil];
}

- (void)tfy_hidesNavigationBarsOnSwipe {
    self.hidesBarsOnSwipe = YES;
}

- (void)tfy_hidesBarsOnTap {
    self.hidesBarsOnTap = YES;
}


#pragma mark - getter
- (BOOL)tfy_translationScale {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)tfy_openScrollLeftPush {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)tfy_disabledGestureHandle {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIColor *)tfy_titleColor {
    UIColor *obj = objc_getAssociatedObject(self, &@selector(tfy_titleColor));
    return obj;
}

- (UIFont *)tfy_titleFont {
    UIFont *obj = objc_getAssociatedObject(self, &@selector(tfy_titleFont));
    return obj;
}

- (UIColor *)tfy_barBackgroundColor {
    UIColor *obj = objc_getAssociatedObject(self, &@selector(tfy_barBackgroundColor));
    return obj;
}

- (UIImage *)tfy_barBackgroundImage {
    UIImage *obj = objc_getAssociatedObject(self, &@selector(tfy_barBackgroundImage));
    return obj;
}

- (UIImage *)tfy_barReturnButtonImage {
    UIImage *obj = objc_getAssociatedObject(self, &@selector(tfy_barReturnButtonImage));
    return obj;
}

- (UIColor *)tfy_barReturnButtonColor {
    UIColor *obj = objc_getAssociatedObject(self, &@selector(tfy_barReturnButtonColor));
    return obj;
}

- (UIColor *)tfy_navShadowColor {
    UIColor *obj = objc_getAssociatedObject(self, &@selector(tfy_navShadowColor));
    return obj;
}

- (UIImage *)tfy_navShadowImage {
    UIImage *obj = objc_getAssociatedObject(self, &@selector(tfy_navShadowImage));
    return obj;
}

- (TFYPopGestureRecognizerDelegate *)popGestureDelegate {
    TFYPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [TFYPopGestureRecognizerDelegate new];
        delegate.navigationController = self;
        delegate.systemTarget         = [self systemTarget];
        delegate.customTarget         = self.navDelegate;
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (TFYNavigationControllerDelegate *)navDelegate {
    TFYNavigationControllerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [TFYNavigationControllerDelegate new];
        delegate.navigationController = self;
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIScreenEdgePanGestureRecognizer *)screenPanGesture {
    UIScreenEdgePanGestureRecognizer *panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.navDelegate action:@selector(panGestureRecognizerAction:)];
        panGesture.edges = UIRectEdgeLeft;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    UIPanGestureRecognizer *panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] init];
        panGesture.maximumNumberOfTouches = 1;
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

- (id)systemTarget {
    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    return internalTarget;
}

#pragma mark - setter
- (void)setTfy_translationScale:(BOOL)tfy_translationScale {
    objc_setAssociatedObject(self, @selector(tfy_translationScale), @(tfy_translationScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTfy_openScrollLeftPush:(BOOL)tfy_openScrollLeftPush {
    objc_setAssociatedObject(self, @selector(tfy_openScrollLeftPush), @(tfy_openScrollLeftPush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTfy_disabledGestureHandle:(BOOL)tfy_disabledGestureHandle {
    objc_setAssociatedObject(self, @selector(tfy_disabledGestureHandle), @(tfy_disabledGestureHandle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTfy_titleColor:(UIColor *)tfy_titleColor {
    objc_setAssociatedObject(self, &@selector(tfy_titleColor), tfy_titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : (tfy_titleColor ? tfy_titleColor : [UIColor blackColor]),NSFontAttributeName : (self.tfy_titleFont ? self.tfy_titleFont : [UIFont fontWithName:@"Helvetica-Bold" size:16])}];
}

- (void)setTfy_titleFont:(UIFont *)tfy_titleFont {
    objc_setAssociatedObject(self, &@selector(tfy_titleFont), tfy_titleFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : (self.tfy_titleColor ? self.tfy_titleColor : [UIColor blackColor]),NSFontAttributeName : (tfy_titleFont ? tfy_titleFont : [UIFont systemFontOfSize:16 weight:UIFontWeightRegular])}];
}

- (void)setTfy_barBackgroundColor:(UIColor *)tfy_barBackgroundColor {
    objc_setAssociatedObject(self, &@selector(tfy_barBackgroundColor), tfy_barBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setBackgroundImage:[self tfy_createImage:tfy_barBackgroundColor] forBarMetrics:UIBarMetricsDefault];
}

- (void)setTfy_barBackgroundImage:(UIImage *)tfy_barBackgroundImage {
    objc_setAssociatedObject(self, &@selector(tfy_barBackgroundImage), tfy_barBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setBackgroundImage:tfy_barBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)setTfy_barReturnButtonImage:(UIImage *)tfy_barReturnButtonImage {
    objc_setAssociatedObject(self, &@selector(tfy_barReturnButtonImage), tfy_barReturnButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationBar.backIndicatorTransitionMaskImage = tfy_barReturnButtonImage;
    self.navigationBar.backIndicatorImage = tfy_barReturnButtonImage;
}

- (void)setTfy_barReturnButtonColor:(UIColor *)tfy_barReturnButtonColor {
    objc_setAssociatedObject(self, &@selector(tfy_barReturnButtonColor), tfy_barReturnButtonColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setTintColor:tfy_barReturnButtonColor];
}

- (void)setTfy_navShadowColor:(UIColor *)tfy_navShadowColor {
    objc_setAssociatedObject(self, &@selector(tfy_navShadowColor), tfy_navShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationBar.shadowImage = [UIImage tfy_changeImage:[UIImage tfy_imageNamed:@"nav_line"] color:tfy_navShadowColor];
}

- (void)setTfy_navShadowImage:(UIImage *)tfy_navShadowImage {
    objc_setAssociatedObject(self, &@selector(tfy_navShadowImage), tfy_navShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationBar.shadowImage = tfy_navShadowImage;
}

- (UIImage *)tfy_createImage:(UIColor *)imageColor {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [imageColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIColor *)tfy_ColorWithHexString:(NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}
@end
