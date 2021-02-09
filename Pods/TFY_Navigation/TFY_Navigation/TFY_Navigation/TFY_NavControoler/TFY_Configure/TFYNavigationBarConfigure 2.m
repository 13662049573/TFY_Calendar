//
//  TFYNavigationBarConfigure.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFYNavigationBarConfigure.h"
#import "UIImage+TFYCategory.h"

@interface TFYNavigationBarConfigure ()
@property (nonatomic, assign) CGFloat navItemLeftSpace;
@property (nonatomic, assign) CGFloat navItemRightSpace;
@end

@implementation TFYNavigationBarConfigure
static TFYNavigationBarConfigure *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TFYNavigationBarConfigure new];
    });
    return instance;
}

// 设置默认的导航栏外观
- (void)setupDefaultConfigure {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleColor      = [UIColor blackColor];
    
    self.titleFont       = [UIFont boldSystemFontOfSize:16.0];
    
    self.statusBarHidden = NO;
    
    self.statusBarStyle  = UIStatusBarStyleDefault;
    
    self.backStyle       = TFYNavigationBarBackStyleBlack;
    
    self.tfy_navItemLeftSpace    = 15;
    self.tfy_navItemRightSpace   = 15;
    
    self.navItemLeftSpace       = 15;
    self.navItemRightSpace      = 15;
    
    self.tfy_pushTransitionCriticalValue = 0.3;
    self.tfy_popTransitionCriticalValue  = 0.5;
    
    self.tfy_translationX = 10.0f;
    self.tfy_translationY = 10.0f;
    self.tfy_scaleX = 0.95;
    self.tfy_scaleY = 0.97;
    
    self.navShadowColor = [self tfy_ColorWithHexString:@"eeeeee"];
}

- (void)setTfy_navItemLeftSpace:(CGFloat)tfy_navItemLeftSpace {
    _tfy_navItemLeftSpace = tfy_navItemLeftSpace;
}

- (void)setTfy_navItemRightSpace:(CGFloat)tfy_navItemRightSpace {
    _tfy_navItemRightSpace = tfy_navItemRightSpace;
}

- (void)setBackStyle:(TFYNavigationBarBackStyle)backStyle {
    _backStyle = backStyle;
    if (_backStyle != TFYNavigationBarBackStyleNone) {
        NSString *imageName = _backStyle == TFYNavigationBarBackStyleBlack ? @"btn_back_black" : @"btn_back_white";
        self.backImage = [UIImage tfy_imageNamed:imageName];
    }
}


- (void)setupCustomConfigure:(void (^)(TFYNavigationBarConfigure *))block {
    [self setupDefaultConfigure];
    
    !block ? : block(self);
    
    self.navItemLeftSpace  = self.tfy_navItemLeftSpace;
    self.navItemRightSpace = self.tfy_navItemRightSpace;
}

// 更新配置
- (void)updateConfigure:(void (^)(TFYNavigationBarConfigure *configure))block {
    !block ? : block(self);
}

- (UIViewController *)visibleViewController {
    return [[TFY_Configure getKeyWindow].rootViewController tfy_visibleViewVCfExist];
}

- (UIEdgeInsets)tfy_safeAreaInsets {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *keyWindow = [TFY_Configure getKeyWindow];
        if (keyWindow) {
            return keyWindow.safeAreaInsets;
        }else { // 如果获取到的window是空
            // 对于刘海屏，当window没有创建的时候，可根据状态栏设置安全区域顶部高度
            // iOS14之后顶部安全区域不再是固定的44，所以修改为以下方式获取
            if ([TFY_Configure tfy_isNotchedScreen]) {
                safeAreaInsets = UIEdgeInsetsMake([TFY_Configure tfy_statusBarFrame].size.height, 0, 34, 0);
            }
        }
    }
    return safeAreaInsets;
}

- (CGRect)tfy_statusBarFrame {
    return [UIApplication sharedApplication].statusBarFrame;
}

- (BOOL)tfy_isNotchedScreen {
    if (@available(iOS 11.0, *)) {
        UIWindow *keyWindow = [TFY_Configure getKeyWindow];
        if (keyWindow) {
            return keyWindow.safeAreaInsets.bottom > 0;
        }
    }
    // 当iOS11以下或获取不到keyWindow时用以下方案
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    return (CGSizeEqualToSize(screenSize, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(896, 414)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(844, 390)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(926, 428)));
}

- (CGFloat)tfy_fixedSpace {
    CGSize screentSize = [UIScreen mainScreen].bounds.size;
    return MIN(screentSize.width, screentSize.height) > 375 ? 20 : 16;
}

- (UIWindow *)getKeyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in windowScene.windows) {
                    if (window.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
        }
    }
    // 没有获取到window
    if (!window) {
        for (UIWindow *w in [UIApplication sharedApplication].windows) {
            if (w.isKeyWindow) {
                window = w;
                break;
            }
        }
    }
    return window;
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

@implementation UIViewController (Common)

- (UIViewController *)tfy_visibleViewVCfExist {
    if (self.presentedViewController) {
        return [self.presentedViewController tfy_visibleViewVCfExist];
    }
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).topViewController tfy_visibleViewVCfExist];
    }
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController tfy_visibleViewVCfExist];
    }
    if ([self isViewLoaded] && self.view.window) {
        return self;
    }else {
        NSLog(@"找不到可见的控制器，viewcontroller.self = %@，self.view.window=%@", self, self.view.window);
        return nil;
    }
}

@end
