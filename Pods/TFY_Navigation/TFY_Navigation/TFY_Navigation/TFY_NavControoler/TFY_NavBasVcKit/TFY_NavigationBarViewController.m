//
//  TFY_NavigationBarViewController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFY_NavigationBarViewController.h"

@interface TFY_NavigationBarViewController ()

@property (nonatomic, strong) TFYNavigationBar   *tfy_navigationBar;

@property (nonatomic, strong) UINavigationItem  *tfy_navigationItem;

@end

@implementation TFY_NavigationBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置自定义导航栏
    [self setupCustomNavBar];
    
    // 设置导航栏外观
    [self setupNavBarAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏系统导航栏
    [self.navigationController setNavigationBarHidden:YES];
    
    // 将自定义导航栏放置顶层
    if (self.tfy_navigationBar && !self.tfy_navigationBar.hidden) {
        [self.view bringSubviewToFront:self.tfy_navigationBar];
    }
    
    // 获取状态
    self.tfy_navigationBar.tfy_statusBarHidden = self.tfy_statusBarHidden;
    
    // 返回按钮样式
    if (self.tfy_backStyle == TFYNavigationBarBackStyleNone) {
        self.tfy_backStyle = TFY_Configure.backStyle;
    }
}

#pragma mark - Public Methods
- (void)showNavLine {
    self.tfy_navLineHidden = NO;
}

- (void)hideNavLine {
    self.tfy_navLineHidden = YES;
}

- (void)refreshNavBarFrame {
    [self setupNavBarFrame];
}

#pragma mark - private Methods
/**
 设置自定义导航条
 */
- (void)setupCustomNavBar {
    
    [self.view addSubview:self.tfy_navigationBar];
    
    [self setupNavBarFrame];
    
    self.tfy_navigationBar.items = @[self.tfy_navigationItem];
}

/**
 设置导航栏外观
 */
- (void)setupNavBarAppearance {
    TFYNavigationBarConfigure *configure = [TFYNavigationBarConfigure sharedInstance];
    
    // 设置默认背景色
    if (configure.backgroundColor) {
        self.tfy_navBackgroundColor = configure.backgroundColor;
    }
    
    // 设置默认标题颜色
    if (configure.titleColor) {
        self.tfy_navTitleColor = configure.titleColor;
    }
    
    // 设置默认标题字体
    if (configure.titleFont) {
        self.tfy_navTitleFont = configure.titleFont;
    }
    
    // 设置默认返回图片
    if (self.tfy_backImage == nil) {
        self.tfy_backImage = configure.backImage;
    }
    
    // 设置默认返回样式
    if (self.tfy_backStyle == TFYNavigationBarBackStyleNone) {
        self.tfy_backStyle = configure.backStyle;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setupNavBarFrame];
}

- (void)setupNavBarFrame {
    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat navBarH = 0;
    if (width > height) { // 横屏
        if (TFY_IS_iPad) {
            CGFloat statusBarH = [TFY_Configure tfy_statusBarFrame].size.height;
            CGFloat navigaBarH = self.navigationController.navigationBar.frame.size.height;
            navBarH = statusBarH + navigaBarH;
        }else if (TFY_IS_iPhoneX) {
            navBarH = TFY_NAVBAR_HEIGHT;
        }else {
            if (width == 736.0f && height == 414.0f) { // plus横屏
                navBarH = self.tfy_statusBarHidden ? TFY_NAVBAR_HEIGHT : TFY_STATUSBAR_NAVBAR_HEIGHT;
            }else { // 其他机型横屏
                navBarH = self.tfy_statusBarHidden ? 32.0f : 52.0f;
            }
        }
    }else { // 竖屏
        navBarH = self.tfy_statusBarHidden ? (TFY_SAFEAREA_TOP + TFY_NAVBAR_HEIGHT) : TFY_STATUSBAR_NAVBAR_HEIGHT;
    }
    
    self.tfy_navigationBar.frame = CGRectMake(0, 0, width, navBarH);
    self.tfy_navigationBar.tfy_statusBarHidden = self.tfy_statusBarHidden;
    [self.tfy_navigationBar layoutSubviews];
}

#pragma mark - 控制状态栏的方法
- (BOOL)prefersStatusBarHidden {
    return self.tfy_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.tfy_statusBarStyle;
}

#pragma mark - 懒加载
- (TFYNavigationBar *)tfy_navigationBar {
    if (!_tfy_navigationBar) {
        _tfy_navigationBar = [[TFYNavigationBar alloc] initWithFrame:CGRectZero];
    }
    return _tfy_navigationBar;
}

- (UINavigationItem *)tfy_navigationItem {
    if (!_tfy_navigationItem) {
        _tfy_navigationItem = [UINavigationItem new];
    }
    return _tfy_navigationItem;
}

#pragma mark - setter
- (void)setTfy_navTitle:(NSString *)tfy_navTitle {
    _tfy_navTitle = tfy_navTitle;
    
    self.tfy_navigationItem.title = tfy_navTitle;
}

- (void)setTfy_navBarTintColor:(UIColor *)tfy_navBarTintColor {
    _tfy_navBarTintColor = tfy_navBarTintColor;
    
    self.tfy_navigationBar.barTintColor = tfy_navBarTintColor;
}

- (void)setTfy_navBackgroundColor:(UIColor *)tfy_navBackgroundColor {
    _tfy_navBackgroundColor = tfy_navBackgroundColor;
    
    [self.tfy_navigationBar setBackgroundImage:[UIImage tfy_imageWithColor:tfy_navBackgroundColor] forBarMetrics:UIBarMetricsDefault];
}

- (void)setTfy_navBackgroundImage:(UIImage *)tfy_navBackgroundImage {
    _tfy_navBackgroundImage = tfy_navBackgroundImage;
    
    [self.tfy_navigationBar setBackgroundImage:tfy_navBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)setTfy_navShadowColor:(UIColor *)tfy_navShadowColor {
    _tfy_navShadowColor = tfy_navShadowColor;
    
    self.tfy_navigationBar.shadowImage = [UIImage tfy_changeImage:[UIImage tfy_imageNamed:@"nav_line"] color:tfy_navShadowColor];
}

- (void)setTfy_navShadowImage:(UIImage *)tfy_navShadowImage {
    _tfy_navShadowImage = tfy_navShadowImage;
    
    self.tfy_navigationBar.shadowImage = tfy_navShadowImage;
}

- (void)setTfy_navTintColor:(UIColor *)tfy_navTintColor {
    _tfy_navTintColor = tfy_navTintColor;
    
    self.tfy_navigationBar.tintColor = tfy_navTintColor;
}

- (void)setTfy_navTitleView:(UIView *)tfy_navTitleView {
    _tfy_navTitleView = tfy_navTitleView;
    
    self.tfy_navigationItem.titleView = tfy_navTitleView;
}

- (void)setTfy_navTitleColor:(UIColor *)tfy_navTitleColor {
    _tfy_navTitleColor = tfy_navTitleColor;
    
    UIFont *titleFont = self.tfy_navTitleFont ? self.tfy_navTitleFont : TFY_Configure.titleFont;
    
    self.tfy_navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: tfy_navTitleColor, NSFontAttributeName: titleFont};
}

- (void)setTfy_navTitleFont:(UIFont *)tfy_navTitleFont {
    _tfy_navTitleFont = tfy_navTitleFont;
    
    UIColor *titleColor = self.tfy_navTitleColor ? self.tfy_navTitleColor : TFY_Configure.titleColor;
    
    self.tfy_navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: titleColor, NSFontAttributeName: tfy_navTitleFont};
}

- (void)setTfy_navLeftBarButtonItem:(UIBarButtonItem *)tfy_navLeftBarButtonItem {
    _tfy_navLeftBarButtonItem = tfy_navLeftBarButtonItem;
    
    self.tfy_navigationItem.leftBarButtonItem = tfy_navLeftBarButtonItem;
}

- (void)setTfy_navLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)tfy_navLeftBarButtonItems {
    _tfy_navLeftBarButtonItems = tfy_navLeftBarButtonItems;
    
    self.tfy_navigationItem.leftBarButtonItems = tfy_navLeftBarButtonItems;
}

- (void)setTfy_navRightBarButtonItem:(UIBarButtonItem *)tfy_navRightBarButtonItem {
    _tfy_navRightBarButtonItem = tfy_navRightBarButtonItem;
    
    self.tfy_navigationItem.rightBarButtonItem = tfy_navRightBarButtonItem;
}

- (void)setTfy_navRightBarButtonItems:(NSArray<UIBarButtonItem *> *)tfy_navRightBarButtonItems {
    _tfy_navRightBarButtonItems = tfy_navRightBarButtonItems;
    
    self.tfy_navigationItem.rightBarButtonItems = tfy_navRightBarButtonItems;
}

- (void)setTfy_navLineHidden:(BOOL)tfy_navLineHidden {
    _tfy_navLineHidden = tfy_navLineHidden;
    
    self.tfy_navigationBar.tfy_navLineHidden = tfy_navLineHidden;
    
    if (@available(iOS 11.0, *)) {
        UIImage *shadowImage = nil;
        if (tfy_navLineHidden) {
            shadowImage = [UIImage new];
        }else if (self.tfy_navShadowImage) {
            shadowImage = self.tfy_navShadowImage;
        }else if (self.tfy_navShadowColor) {
            shadowImage = [UIImage tfy_changeImage:[UIImage tfy_imageNamed:@"nav_line"] color:self.tfy_navShadowColor];
        }
        self.tfy_navigationBar.shadowImage = shadowImage;
    }
    
    [self.tfy_navigationBar layoutSubviews];
}


@end


@implementation UIViewController (NavigationBar)

- (void)setTfy_navBaseBarAlpha:(CGFloat)tfy_navBaseBarAlpha {
    objc_setAssociatedObject(self, @selector(tfy_navBaseBarAlpha), @(tfy_navBaseBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    TFY_NavigationBarViewController *vc = (TFY_NavigationBarViewController *)self;
    vc.tfy_navigationBar.tfy_navBarBackgroundAlpha = tfy_navBaseBarAlpha;
}

-(CGFloat)tfy_navBaseBarAlpha {
    id obj = objc_getAssociatedObject(self, @selector(tfy_navBaseBarAlpha));
    return obj ? [obj floatValue] : 1.0f;
}


@end
