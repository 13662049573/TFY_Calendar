//
//  UINavigationController+TFY_Extension.m
//  WYBasisKit
//
//  Created by 田风有 on 2019/03/27.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "UINavigationController+TFY_Extension.h"
#include <objc/runtime.h>

static NSString *const barReturnButtonDelegate = @"barReturnButtonDelegate";

@implementation UINavigationController (TFY_Extension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(tfy_viewDidLoad);
        
        Method originMethod = class_getInstanceMethod(class, originSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        } else {
            method_exchangeImplementations(originMethod, swizzledMethod);
        }
    });
}

- (void)tfy_viewDidLoad {
    [self tfy_viewDidLoad];
    objc_setAssociatedObject(self, [barReturnButtonDelegate UTF8String], self.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
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

- (UIColor *)tfy_titleColor {
    UIColor *obj = objc_getAssociatedObject(self, &@selector(tfy_titleColor));
    return obj;
}

- (void)setTfy_titleColor:(UIColor *)tfy_titleColor {
    objc_setAssociatedObject(self, &@selector(tfy_titleColor), tfy_titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : (tfy_titleColor ? tfy_titleColor : [UIColor blackColor]),NSFontAttributeName : (self.tfy_titleFont ? self.tfy_titleFont : [UIFont fontWithName:@"Helvetica-Bold" size:16])}];
}

- (UIFont *)tfy_titleFont {
    UIFont *obj = objc_getAssociatedObject(self, &@selector(tfy_titleFont));
    return obj;
}
- (void)setTfy_titleFont:(UIFont *)tfy_titleFont {
    objc_setAssociatedObject(self, &@selector(tfy_titleFont), tfy_titleFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : (self.tfy_titleColor ? self.tfy_titleColor : [UIColor blackColor]),NSFontAttributeName : (tfy_titleFont ? tfy_titleFont : [UIFont systemFontOfSize:16 weight:UIFontWeightRegular])}];
}

- (UIColor *)tfy_barBackgroundColor {
    UIColor *obj = objc_getAssociatedObject(self, &@selector(tfy_barBackgroundColor));
    return obj;
}
- (void)setTfy_barBackgroundColor:(UIColor *)tfy_barBackgroundColor {
    objc_setAssociatedObject(self, &@selector(tfy_barBackgroundColor), tfy_barBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setBackgroundImage:[self tfy_createImage:tfy_barBackgroundColor] forBarMetrics:UIBarMetricsDefault];
}

- (UIImage *)tfy_barBackgroundImage {
    UIImage *obj = objc_getAssociatedObject(self, &@selector(tfy_barBackgroundImage));
    return obj;
}

- (void)setTfy_barBackgroundImage:(UIImage *)tfy_barBackgroundImage {
    objc_setAssociatedObject(self, &@selector(tfy_barBackgroundImage), tfy_barBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setBackgroundImage:tfy_barBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)tfy_hidesNavigationBarsOnSwipe {
    self.hidesBarsOnSwipe = YES;
}

- (void)tfy_hidesBarsOnTap {
    self.hidesBarsOnTap = YES;
}

- (UIImage *)tfy_barReturnButtonImage {
    UIImage *obj = objc_getAssociatedObject(self, &@selector(tfy_barReturnButtonImage));
    return obj;
}

- (void)setTfy_barReturnButtonImage:(UIImage *)tfy_barReturnButtonImage {
    objc_setAssociatedObject(self, &@selector(tfy_barReturnButtonImage), tfy_barReturnButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.navigationBar.backIndicatorTransitionMaskImage = tfy_barReturnButtonImage;
    self.navigationBar.backIndicatorImage = tfy_barReturnButtonImage;
}

- (UIColor *)tfy_barReturnButtonColor {
    UIColor *obj = objc_getAssociatedObject(self, &@selector(tfy_barReturnButtonColor));
    return obj;
}

- (void)setTfy_barReturnButtonColor:(UIColor *)tfy_barReturnButtonColor {
    objc_setAssociatedObject(self, &@selector(tfy_barReturnButtonColor), tfy_barReturnButtonColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationBar setTintColor:tfy_barReturnButtonColor];
}

#pragma mark - 按钮
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    BOOL shouldPop = YES;
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        // 取消 pop 后，复原返回按钮的状态
        for(UIView *subview in [navigationBar subviews]) {
            if(0. < subview.alpha && subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    return NO;
}

#pragma mark - 手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate> originDelegate = objc_getAssociatedObject(self, [barReturnButtonDelegate UTF8String]);
        return [originDelegate gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
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
