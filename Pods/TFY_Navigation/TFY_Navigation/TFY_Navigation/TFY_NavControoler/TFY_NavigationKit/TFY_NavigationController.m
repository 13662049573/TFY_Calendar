//
//  TFY_NavigationController.m
//
//  Created by 田风有 on 2019/03/27.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_NavigationController.h"
#import <objc/runtime.h>

static char const RootNavigationControllerKey = '\0';

#pragma mark - 容器控制器
@interface TFYContainerViewController : UIViewController

@property (nonatomic, weak) UIViewController *contentViewController;
@property (nonatomic, weak) UINavigationController *containerNavigationController;

+ (instancetype)containerViewControllerWithViewController:(UIViewController *)viewController;
- (instancetype)initWithViewController:(UIViewController *)viewController;

@end

@implementation TFYContainerViewController

+ (instancetype)containerViewControllerWithViewController:(UIViewController *)viewController {
    return [[self alloc] initWithViewController:viewController];
}


- (instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        if (viewController.parentViewController) {
            [viewController willMoveToParentViewController:nil];
            [viewController removeFromParentViewController];
        }
        
        Class cls = [viewController tfy_navigationControllerClass];
        NSAssert(![cls isKindOfClass:UINavigationController.class], @"`-tfy_navigationControllerClass` must return UINavigationController or its subclasses.");
        UINavigationController *navigationController = [[cls alloc] initWithRootViewController:viewController];
        navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        self.contentViewController = viewController;
        self.containerNavigationController = navigationController;
        self.tabBarItem = viewController.tabBarItem;
        self.hidesBottomBarWhenPushed = viewController.hidesBottomBarWhenPushed;
        [self addChildViewController:navigationController];
        [self.view addSubview:navigationController.view];

        navigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                    metrics:nil
                                                      views:@{@"view": navigationController.view}]
        ];
        [NSLayoutConstraint activateConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                    metrics:nil
                                                      views:@{@"view": navigationController.view}]
        ];
        [navigationController didMoveToParentViewController:self];
    }
    return self;
}

@end


#pragma mark - 全局函数

/// 装包
UIKIT_STATIC_INLINE TFYContainerViewController* TFYWrapViewController(UIViewController *vc) {
    if ([vc isKindOfClass:TFYContainerViewController.class]) {
        return (TFYContainerViewController *)vc;
    }
    return [TFYContainerViewController containerViewControllerWithViewController:vc];
}

/// 解包
UIKIT_STATIC_INLINE UIViewController* TFYUnwrapViewController(UIViewController *vc) {
    if ([vc isKindOfClass:TFYContainerViewController.class]) {
        return ((TFYContainerViewController*)vc).contentViewController;
    }
    return vc;
}

/// 替换方法实现
UIKIT_STATIC_INLINE void TFY_swizzled(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - 导航栏控制器

@interface TFY_NavigationController ()
@end

@implementation TFY_NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
        
    [TFY_Configure setupDefaultConfigure];
    
    [self setupNavigationBarTheme];
}

- (void)setupNavigationBarTheme
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    if ([TFY_Configure.backgroundImage isKindOfClass:UIImage.class] && TFY_Configure.backgroundImage!=nil) {
        [navBar setBackgroundImage:TFY_Configure.backgroundImage forBarMetrics:UIBarMetricsDefault];
    } else {
        [navBar setBackgroundImage:[self tfy_createImage:TFY_Configure.backgroundColor] forBarMetrics:UIBarMetricsDefault];
    }
    [navBar setShadowImage:[self tfy_createImage:TFY_Configure.navShadowColor]];
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = TFY_Configure.titleFont;
    textAttrs[NSForegroundColorAttributeName] = TFY_Configure.titleColor;
    [navBar setTitleTextAttributes:textAttrs];
}

#pragma mark Lifecycle

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    TFYContainerViewController *container = TFYWrapViewController(viewController);
    if (self.viewControllers.count >= 1) {
       container.hidesBottomBarWhenPushed = YES;
    }
    // 返回按钮目前仅支持图片
    UIImage *leftImage = [TFY_Configure.backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if (self.viewControllers.count > 0) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:leftImage style:UIBarButtonItemStylePlain target:viewController action:@selector(tfy_popViewController)];
        #pragma clang diagnostic pop
         viewController.navigationItem.leftBarButtonItem = leftItem;
    }

    [super pushViewController:container animated:animated];
    
    objc_setAssociatedObject(container.containerNavigationController, &RootNavigationControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
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

#pragma mark Private

- (void)commonInit {
    UIViewController *topViewController = self.topViewController;
    if (topViewController) {
        UIViewController *wrapViewController = TFYWrapViewController(topViewController);
        [super setViewControllers:@[wrapViewController] animated:NO];
    }
    [self setNavigationBarHidden:YES animated:NO];
}

#pragma mark setter & getter

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [super setNavigationBarHidden:YES];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    NSMutableArray<UIViewController *> *aViewControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        [aViewControllers addObject:TFYWrapViewController(vc)];
    }
    [super setViewControllers:aViewControllers animated:animated];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    NSMutableArray<UIViewController *> *aViewControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        [aViewControllers addObject:TFYWrapViewController(vc)];
    }
    [super setViewControllers:[NSArray arrayWithArray:aViewControllers]];
}

- (NSArray<UIViewController *> *)viewControllers {
    //返回真正的控制器给外界
    NSMutableArray<UIViewController *> *vcs = [NSMutableArray array];
    NSArray<UIViewController *> *viewControllers = [super viewControllers];
    for (UIViewController *vc in viewControllers) {
        [vcs addObject:TFYUnwrapViewController(vc)];
    }
    return [NSArray arrayWithArray:vcs];
}

@end


#pragma mark -

@implementation UIViewController (TFYNavigationContainer)

/// 通过返回不同的导航栏控制器可以给每个控制器定制不同的导航栏样式
- (Class)tfy_navigationControllerClass {
#ifdef kTFYNavigationControllerClassName
    return NSClassFromString(kTFYNavigationControllerClassName);
#else
    return [TFYContainerNavigationController class];
#endif
}

- (TFY_NavigationController *)tfy_rootNavigationController {
    UIViewController *parentViewController = self.navigationController.parentViewController;
    if (parentViewController && [parentViewController isKindOfClass:TFYContainerViewController.class]) {
        TFYContainerViewController *container = (TFYContainerViewController*)parentViewController;
        return (TFY_NavigationController*)container.navigationController;
    }
    return nil;
}

- (void)tfy_popViewController {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end


#pragma mark -

@interface UINavigationController (TFYNavigationContainer)
@end

@implementation UINavigationController (TFYNavigationContainer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *actions = @[
                             NSStringFromSelector(@selector(pushViewController:animated:)),
                             NSStringFromSelector(@selector(popViewControllerAnimated:)),
                             NSStringFromSelector(@selector(popToViewController:animated:)),
                             NSStringFromSelector(@selector(popToRootViewControllerAnimated:)),
                             NSStringFromSelector(@selector(viewControllers))
                             ];
        for (NSString *str in actions) {
            TFY_swizzled(self, NSSelectorFromString(str), NSSelectorFromString([@"tfy_" stringByAppendingString:str]));
        }
    });
}

#pragma mark Private

- (TFY_NavigationController *)rootNavigationController {
    if (self.parentViewController && [self.parentViewController isKindOfClass:TFYContainerViewController.class]) {
        TFYContainerViewController *containerViewController = (TFYContainerViewController *)self.parentViewController;
        TFY_NavigationController *rootNavigationController = (TFY_NavigationController *)containerViewController.navigationController;
        // 如果用户执行了pop操作, 则此时`rootNavigationController`将为nil
        // 将尝试从关联对象中取出`XPRootNavigationController`
        return (rootNavigationController ?: objc_getAssociatedObject(self, &RootNavigationControllerKey));
    }
    return nil;
}

#pragma mark Override

- (void)tfy_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    TFY_NavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        return [rootNavigationController pushViewController:viewController animated:animated];;
    }
    [self tfy_pushViewController:viewController animated:animated];
}

- (UIViewController *)tfy_popViewControllerAnimated:(BOOL)animated {
    TFY_NavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        TFYContainerViewController *containerViewController = (TFYContainerViewController*)[rootNavigationController popViewControllerAnimated:animated];
        return containerViewController.contentViewController;
    }
    return [self tfy_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)tfy_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    TFY_NavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        TFYContainerViewController *container = (TFYContainerViewController*)viewController.navigationController.parentViewController;
        NSArray<UIViewController*> *array = [rootNavigationController popToViewController:container animated:animated];
        NSMutableArray *viewControllers = [NSMutableArray array];
        for (UIViewController *vc in array) {
            [viewControllers addObject:TFYUnwrapViewController(vc)];
        }
        return viewControllers;
    }
    return [self tfy_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)tfy_popToRootViewControllerAnimated:(BOOL)animated {
    TFY_NavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        NSArray<UIViewController*> *array = [rootNavigationController popToRootViewControllerAnimated:animated];
        NSMutableArray *viewControllers = [NSMutableArray array];
        for (UIViewController *vc in array) {
            [viewControllers addObject:TFYUnwrapViewController(vc)];
        }
        return viewControllers;
    }
    return [self tfy_popToRootViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)tfy_viewControllers {
    TFY_NavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        return [rootNavigationController viewControllers];
    }
    return [self tfy_viewControllers];
}

- (UITabBarController *)tfy_tabBarController {
    UITabBarController *tabController = [self tfy_tabBarController];
    if (self.parentViewController && [self.parentViewController isKindOfClass:TFYContainerViewController.class]) {
        if (self.viewControllers.count > 1 && self.topViewController.hidesBottomBarWhenPushed) {
            // 解决滚动视图在iOS11以下版本中底部留白问题
            return nil;
        }
        if (!tabController.tabBar.isTranslucent) {
            return nil;
        }
    }
    return tabController;
}


@end


#pragma mark - 状态栏样式 & 屏幕旋转

@implementation TFYContainerNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.topViewController) {
        return TFYUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.topViewController) {
        return TFYUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) preferredStatusBarStyle];
    }
    return [super preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) preferredStatusBarUpdateAnimation];
    }
    return [super preferredStatusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden {
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) prefersStatusBarHidden];
    }
    return [super prefersStatusBarHidden];
}

- (BOOL)shouldAutorotate {
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) shouldAutorotate];
    }
    return [super shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) preferredInterfaceOrientationForPresentation];
    }
    return [super preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

#if __IPHONE_11_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (nullable UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures
{
    if (self.topViewController) {
        return TFYUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForScreenEdgesDeferringSystemGestures];
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) preferredScreenEdgesDeferringSystemGestures];
    }
    return [super preferredScreenEdgesDeferringSystemGestures];
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    if (self.topViewController) {
        return [TFYUnwrapViewController(self.topViewController) prefersHomeIndicatorAutoHidden];
    }
    return [super prefersHomeIndicatorAutoHidden];
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
    if (self.topViewController) {
        return TFYUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}
#endif

@end
