//
//  UIViewController+RootNavigation.m
//  RootNavigation
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import "UIViewController+RootNavigation.h"
#import "TFY_NavigationController.h"
#import <objc/runtime.h>

#if __has_include(<TFYThemeKit.h>)
#import <TFYThemeKit.h>
#elif __has_include("TFYThemeKit.h")
#import "TFYThemeKit.h"
#endif

CG_INLINE BOOL Nav_iPhoneX(void) {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((NSInteger)(([[UIScreen mainScreen] currentMode].size.height/[[UIScreen mainScreen] currentMode].size.width)*100) == 216) : NO);
}
/**导航栏高度*/
CG_INLINE CGFloat Nav_kNavBarHeight(void) {
    return (Nav_iPhoneX() ? 88.0 : 64.0);
}

@interface UIColor (navHex)
+ (UIColor *)colorWithHexString:(NSString *)color;
//从十六进制字符串获取颜色，
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end

@implementation UIViewController (RootNavigation)
@dynamic tfy_disableInteractivePop;

- (void)setTfy_disableInteractivePop:(BOOL)tfy_disableInteractivePop
{
    objc_setAssociatedObject(self, @selector(tfy_disableInteractivePop), @(tfy_disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.tfy_navigationController.tfy_topViewController == self) {
        self.tfy_navigationController.interactivePopGestureRecognizer.enabled = !tfy_disableInteractivePop;
    }
}

- (BOOL)tfy_disableInteractivePop
{
    return [objc_getAssociatedObject(self, @selector(tfy_disableInteractivePop)) boolValue];
}

- (Class)tfy_navigationBarClass
{
    return nil;
}

- (TFY_NavigationController *)tfy_navigationController
{
    UIViewController *vc = self;
    while (vc && ![vc isKindOfClass:[TFY_NavigationController class]]) {
        vc = vc.navigationController;
    }
    return (TFY_NavigationController *)vc;
}

- (void)setTfy_isHiddenNavBar:(BOOL)tfy_isHiddenNavBar {
    NSNumber *number = [NSNumber numberWithBool:tfy_isHiddenNavBar];
    objc_setAssociatedObject(self, @selector(tfy_isHiddenNavBar), number, OBJC_ASSOCIATION_ASSIGN);
    [self hiddenNavigationBar];
}

- (BOOL)tfy_isHiddenNavBar {
    NSNumber *number = objc_getAssociatedObject(self, @selector(tfy_isHiddenNavBar));
    return number.boolValue;
}

- (void)hiddenNavigationBar {
    [self setNavigationBackgroundColor:UIColor.clearColor];
}

- (void)setTfy_alphaFloat:(CGFloat)tfy_alphaFloat {
    NSNumber *number = [NSNumber numberWithBool:tfy_alphaFloat];
    objc_setAssociatedObject(self, @selector(tfy_alphaFloat), number, OBJC_ASSOCIATION_ASSIGN);
    [self contentOffset:tfy_alphaFloat];
}

- (CGFloat)tfy_alphaFloat {
    NSNumber *number = objc_getAssociatedObject(self, @selector(tfy_alphaFloat));
    return number.floatValue;
}
- (void)contentOffset:(CGFloat)offectY {
    CGFloat alphaIndex = (CGFloat)(offectY/Nav_kNavBarHeight());
    NSString *colorStr = self.tfy_alphaColor.length > 0?self.tfy_alphaColor:@"ffffff";
    [self setNavigationBackgroundColor:[UIColor colorWithHexString:colorStr alpha:alphaIndex]];
}

- (void)setTfy_navBackgroundColor:(UIColor *)tfy_navBackgroundColor {
    objc_setAssociatedObject(self, @selector(tfy_navBackgroundColor), tfy_navBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNavigationBackgroundColor:tfy_navBackgroundColor];
}

- (UIColor *)tfy_navBackgroundColor {
    return objc_getAssociatedObject(self, @selector(tfy_navBackgroundColor));
}

- (void)setTfy_alphaColor:(NSString *)tfy_alphaColor {
    objc_setAssociatedObject(self, @selector(tfy_alphaColor), tfy_alphaColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self contentOffset:Nav_kNavBarHeight()];
}

- (NSString *)tfy_alphaColor {
    return objc_getAssociatedObject(self, @selector(tfy_alphaColor));
}

- (id<UIViewControllerAnimatedTransitioning>)tfy_animatedTransitioning
{
    return nil;
}

/// 设置导航栏颜色
-(void)setNavigationBackgroundColor:(UIColor *)color {
#if __has_include(<TFYThemeKit.h>) || __has_include("TFYThemeKit.h")
#else
    NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor blackColor],
                              NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightMedium]};
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = color;// 背景色
        appearance.backgroundEffect = nil;// 去掉半透明效果
        appearance.titleTextAttributes = dic;// 标题字体颜色及大小
        appearance.shadowImage = [[UIImage alloc] init];// 设置导航栏下边界分割线透明
        appearance.shadowColor = [UIColor clearColor];// 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
        appearance.backgroundImage = [self createImage:color];
        appearance.backgroundColor = color;
        self.navigationController.navigationBar.standardAppearance = appearance;// standardAppearance：常规状态, 标准外观，iOS15之后不设置的时候，导航栏背景透明
        if (@available(iOS 15.0, *)) {
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;// scrollEdgeAppearance：被scrollview向下拉的状态, 滚动时外观，不设置的时候，使用标准外观
        }
    } else {
        self.navigationController.navigationBar.titleTextAttributes = dic;
        [self.navigationController.navigationBar setShadowImage:UIImage.new];
        [self.navigationController.navigationBar setBackgroundImage:[self createImage:color] forBarMetrics:UIBarMetricsDefault];
    }
#endif
}

- (UIImage *)createImage:(UIColor *)imageColor {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [imageColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIColor (navHex)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}

@end
