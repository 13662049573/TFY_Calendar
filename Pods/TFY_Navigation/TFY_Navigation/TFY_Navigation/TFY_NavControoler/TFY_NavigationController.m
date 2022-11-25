//
//  TFY_NavigationController.m
//  TFY_NavigationController
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import "TFY_NavigationController.h"
#import <objc/runtime.h>

@interface NSArray<ObjectType> (TFY_NavigationController)
- (NSArray *)tfy_map:(id(^)(ObjectType obj, NSUInteger index))block;
- (BOOL)tfy_any:(BOOL(^)(ObjectType obj))block;
@end

@implementation NSArray (TFY_NavigationController)

- (NSArray *)tfy_map:(id (^)(id obj, NSUInteger index))block
{
    if (!block) {
        block = ^(id obj, NSUInteger index) {
            return obj;
        };
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        [array addObject:block(obj, idx)];
    }];
    return [NSArray arrayWithArray:array];
}

- (BOOL)tfy_any:(BOOL (^)(id))block
{
    if (!block)
        return NO;
    __block BOOL result = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        if (block(obj)) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

@end

@interface TFYContainerController ()
@property (nonatomic, strong) __kindof UIViewController *contentViewController;
@property (nonatomic, strong) UINavigationController *containerNavigationController;

+ (instancetype)containerControllerWithController:(UIViewController *)controller;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle;

- (instancetype)initWithController:(UIViewController *)controller;
- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass;

@end


static inline UIViewController *TFYSafeUnwrapViewController(UIViewController *controller) {
    if ([controller isKindOfClass:[TFYContainerController class]]) {
        return ((TFYContainerController *)controller).contentViewController;
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *TFYSafeWrapViewController(UIViewController *controller,
                                                                                     Class navigationBarClass,
                                                                                     BOOL withPlaceholder,
                                                                                     UIBarButtonItem *backItem,
                                                                                     NSString *backTitle) {
    if (![controller isKindOfClass:[TFYContainerController class]] &&
        ![controller.parentViewController isKindOfClass:[TFYContainerController class]]) {
        return [TFYContainerController containerControllerWithController:controller
                                                     navigationBarClass:navigationBarClass
                                              withPlaceholderController:withPlaceholder
                                                      backBarButtonItem:backItem
                                                              backTitle:backTitle];
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *TFYSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder) {
    if (![controller isKindOfClass:[TFYContainerController class]] &&
        ![controller.parentViewController isKindOfClass:[TFYContainerController class]]) {
        return [TFYContainerController containerControllerWithController:controller
                                                     navigationBarClass:navigationBarClass
                                              withPlaceholderController:withPlaceholder];
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *TFYSafeWrapViewController(UIViewController *controller, Class navigationBarClass) {
    return TFYSafeWrapViewController(controller, navigationBarClass, NO);
}


@interface TFY_NavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<UINavigationControllerDelegate> tfy_delegate;
@property (nonatomic, copy) void(^animationBlock)(BOOL finished);
- (void)_installsLeftBarButtonItemIfNeededForViewController:(UIViewController *)vc;
@end

@implementation TFYContainerController

+ (instancetype)containerControllerWithController:(UIViewController *)controller
{
    return [[self alloc] initWithController:controller];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
{
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo
{
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass
                  withPlaceholderController:yesOrNo];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle
{
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass
                  withPlaceholderController:yesOrNo
                          backBarButtonItem:backItem
                                  backTitle:backTitle];
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass
         withPlaceholderController:(BOOL)yesOrNo
                 backBarButtonItem:(UIBarButtonItem *)backItem
                         backTitle:(NSString *)backTitle
{
    self = [super init];
    if (self) {
        self.contentViewController = controller;
        self.containerNavigationController = [[TFYContainerNavigationController alloc] initWithNavigationBarClass:navigationBarClass
                                                                                                    toolbarClass:nil];
        if (yesOrNo) {
            UIViewController *vc = [UIViewController new];
            vc.title = backTitle;
            vc.navigationItem.backBarButtonItem = backItem;
            self.containerNavigationController.viewControllers = @[vc, controller];
        }
        else
            self.containerNavigationController.viewControllers = @[controller];
        
        [self addChildViewController:self.containerNavigationController];
        [self.containerNavigationController didMoveToParentViewController:self];
    }
    return self;
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass
         withPlaceholderController:(BOOL)yesOrNo
{
    return [self initWithController:controller
                 navigationBarClass:navigationBarClass
          withPlaceholderController:yesOrNo
                  backBarButtonItem:nil
                          backTitle:nil];
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass
{
    return [self initWithController:controller
                 navigationBarClass:navigationBarClass
          withPlaceholderController:NO];
}

- (instancetype)initWithController:(UIViewController *)controller
{
    return [self initWithController:controller navigationBarClass:nil];
}

- (instancetype)initWithContentController:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        self.contentViewController = controller;
        [self addChildViewController:self.contentViewController];
        [self.contentViewController didMoveToParentViewController:self];
    }
    return self;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p contentViewController: %@>", self.class, self, self.contentViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.containerNavigationController) {
        self.containerNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.containerNavigationController.view];
    
        self.containerNavigationController.view.frame = self.view.bounds;
    }
    else {
        self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentViewController.view.frame = self.view.bounds;
        [self.view addSubview:self.contentViewController.view];
    }
    self.containerNavigationController.view.backgroundColor = UIColor.whiteColor;
}

- (BOOL)becomeFirstResponder
{
    return [self.contentViewController becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return [self.contentViewController canBecomeFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.contentViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.contentViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.contentViewController preferredStatusBarUpdateAnimation];
}

#if __IPHONE_11_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (nullable UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures
{
    return self.contentViewController;
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return [self.contentViewController preferredScreenEdgesDeferringSystemGestures];
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    return [self.contentViewController prefersHomeIndicatorAutoHidden];
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
    return self.contentViewController;
}
#endif

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.contentViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.contentViewController.preferredInterfaceOrientationForPresentation;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return self.contentViewController.hidesBottomBarWhenPushed;
}

- (NSString *)title
{
    return self.contentViewController.title;
}

- (UITabBarItem *)tabBarItem
{
    return self.contentViewController.tabBarItem;
}

- (id<UIViewControllerAnimatedTransitioning>)tfy_animatedTransitioning
{
    return self.contentViewController.tfy_animatedTransitioning;
}

#if RT_INTERACTIVE_PUSH
- (nullable __kindof UIViewController *)tfy_nextSiblingController
{
    return self.contentViewController.tfy_nextSiblingController;
}
#endif

@end

@interface UIViewController (TFYContainerNavigationController)
@property (nonatomic, assign, readonly) BOOL tfy_hasSetInteractivePop;
@end

@implementation UIViewController (TFYContainerNavigationController)

- (BOOL)tfy_hasSetInteractivePop
{
    return !!objc_getAssociatedObject(self, @selector(tfy_disableInteractivePop));
}

@end


@implementation TFYContainerNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:rootViewController.tfy_navigationBarClass
                                toolbarClass:nil];
    if (self) {
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.enabled = NO;
    
    if (self.tfy_navigationController.transferNavigationBarAttributes) {
        self.navigationBar.translucent     = self.navigationController.navigationBar.isTranslucent;
        self.navigationBar.tintColor       = self.navigationController.navigationBar.tintColor;
        self.navigationBar.barTintColor    = self.navigationController.navigationBar.barTintColor;
        self.navigationBar.barStyle        = self.navigationController.navigationBar.barStyle;
        self.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
        
        [self.navigationBar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]
                                 forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTitleVerticalPositionAdjustment:[self.navigationController.navigationBar titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault]
                                                 forBarMetrics:UIBarMetricsDefault];
        
        self.navigationBar.titleTextAttributes              = self.navigationController.navigationBar.titleTextAttributes;
        self.navigationBar.shadowImage                      = self.navigationController.navigationBar.shadowImage;
        self.navigationBar.backIndicatorImage               = self.navigationController.navigationBar.backIndicatorImage;
        self.navigationBar.backIndicatorTransitionMaskImage = self.navigationController.navigationBar.backIndicatorTransitionMaskImage;
    }
    
    [self setupNavigationBarTheme];
}

- (void)setupNavigationBarTheme
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setBackgroundImage:[self createImage:UIColor.whiteColor] forBarMetrics:UIBarMetricsDefault];
    [navBar setShadowImage:[UIImage imageNamed:@"TFY_NavigationImage.bundle/nav_line"]];
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    textAttrs[NSForegroundColorAttributeName] = UIColor.blackColor;
    [navBar setTitleTextAttributes:textAttrs];
}

/// 设置导航栏颜色
-(void)setNavigationBackgroundColor:(UIColor *)color {
    
    NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor blackColor],
                              NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightMedium]};
    
    if (@available(iOS 15.0, *)) {
    
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        
        appearance.backgroundColor = color;// 背景色
        appearance.backgroundEffect = nil;// 去掉半透明效果
        appearance.titleTextAttributes = dic;// 标题字体颜色及大小
        appearance.shadowImage = [[UIImage alloc] init];// 设置导航栏下边界分割线透明
        appearance.shadowColor = [UIColor clearColor];// 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
        appearance.backgroundImage = [self createImage:color];
        
        self.navigationBar.standardAppearance = appearance;// standardAppearance：常规状态, 标准外观，iOS15之后不设置的时候，导航栏背景透明
        self.navigationBar.scrollEdgeAppearance = appearance;// scrollEdgeAppearance：被scrollview向下拉的状态, 滚动时外观，不设置的时候，使用标准外观
        
    } else {

        self.navigationBar.titleTextAttributes = dic;
        [self.navigationBar setShadowImage:[[UIImage alloc] init]];
        [self.navigationBar setBackgroundImage:[self createImage:color] forBarMetrics:UIBarMetricsDefault];
    }
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIViewController *viewController = self.topViewController;
    if (!viewController.tfy_hasSetInteractivePop) {
        BOOL hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil;
        if (self.navigationBarHidden) {
            viewController.tfy_disableInteractivePop = YES;
        } else if (hasSetLeftItem) {
            viewController.tfy_disableInteractivePop = YES;
        } else {
            viewController.tfy_disableInteractivePop = NO;
        }
        
    }
    if ([self.parentViewController isKindOfClass:[TFYContainerController class]] &&
        [self.parentViewController.parentViewController isKindOfClass:[TFY_NavigationController class]]) {
        [self.tfy_navigationController _installsLeftBarButtonItemIfNeededForViewController:viewController];
    }
}

- (UITabBarController *)tabBarController
{
    UITabBarController *tabController = [super tabBarController];
    TFY_NavigationController *navigationController = self.tfy_navigationController;
    if (tabController) {
        if (navigationController.tabBarController != tabController) {
            return tabController;
        }
        else {
            return !tabController.tabBar.isTranslucent || [navigationController.tfy_viewControllers tfy_any:^BOOL(__kindof UIViewController *obj) {
                return obj.hidesBottomBarWhenPushed;
            }] ? nil : tabController;
        }
    }
    return nil;
}

- (NSArray *)viewControllers
{
    if (self.navigationController) {
        if ([self.navigationController isKindOfClass:[TFY_NavigationController class]]) {
            return self.tfy_navigationController.tfy_viewControllers;
        }
    }
    return [super viewControllers];
}

- (NSArray<UIViewController *> *)allowedChildViewControllersForUnwindingFromSource:(UIStoryboardUnwindSegueSource *)source
{
    if (self.navigationController) {
        return [self.navigationController allowedChildViewControllersForUnwindingFromSource:source];
    }
    return [super allowedChildViewControllersForUnwindingFromSource:source];
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController
                                             animated:animated];
    }
    else {
        [super pushViewController:viewController
                         animated:animated];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.navigationController respondsToSelector:aSelector])
        return self.navigationController;
    return nil;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (self.navigationController)
        return [self.navigationController popViewControllerAnimated:animated];
    return [super popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (self.navigationController)
        return [self.navigationController popToRootViewControllerAnimated:animated];
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                     animated:(BOOL)animated
{
    if (self.navigationController)
        return [self.navigationController popToViewController:viewController
                                                     animated:animated];
    return [super popToViewController:viewController
                             animated:animated];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
    if (self.navigationController)
        [self.navigationController setViewControllers:viewControllers
                                             animated:animated];
    else
        [super setViewControllers:viewControllers animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if (self.navigationController)
        self.navigationController.delegate = delegate;
    else
        [super setDelegate:delegate];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [super setNavigationBarHidden:hidden animated:animated];
    if (!self.visibleViewController.tfy_hasSetInteractivePop) {
        self.visibleViewController.tfy_disableInteractivePop = hidden;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.topViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.topViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.topViewController preferredStatusBarUpdateAnimation];
}

#if __IPHONE_11_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (nullable UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures
{
    return self.topViewController;
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return [self.topViewController preferredScreenEdgesDeferringSystemGestures];
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    return [self.topViewController prefersHomeIndicatorAutoHidden];
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
    return self.topViewController;
}
#endif

@end


@implementation TFY_NavigationController

#pragma mark - Methods

- (void)onBack:(id)sender
{
    if ([self.uiNaviDelegate respondsToSelector:@selector(navigationControllerDidClickLeftButton:)]) {
        [self.uiNaviDelegate navigationControllerDidClickLeftButton:self];
    }
    [self popViewControllerAnimated:YES];
}

- (void)_commonInit
{
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)_installsLeftBarButtonItemIfNeededForViewController:(UIViewController *)viewController
{
    BOOL isRootVC = viewController == TFYSafeUnwrapViewController(self.viewControllers.firstObject);
    BOOL hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil;
    if (!isRootVC && !self.useSystemBackBarButtonItem && !hasSetLeftItem) {
        if ([viewController respondsToSelector:@selector(tfy_customBackItemWithTarget:action:)]) {
            viewController.navigationItem.leftBarButtonItem = [viewController tfy_customBackItemWithTarget:self
                                                                                                   action:@selector(onBack:)];
        } else {
            UIImage *image = [[UIImage imageNamed:@"TFY_NavigationImage.bundle/btn_back_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:self
                                                                                              action:@selector(onBack:)];
        }
    }
}


- (UIImage *)navigationBarBackIconImage {
    CGSize const size = CGSizeMake(15.0, 21.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    UIColor *color = UIColor.blackColor;
    [color setFill];
    [color setStroke];
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(10.9, 0)];
    [bezierPath addLineToPoint: CGPointMake(12, 1.1)];
    [bezierPath addLineToPoint: CGPointMake(1.1, 11.75)];
    [bezierPath addLineToPoint: CGPointMake(0, 10.7)];
    [bezierPath addLineToPoint: CGPointMake(10.9, 0)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(11.98, 19.9)];
    [bezierPath addLineToPoint: CGPointMake(10.88, 21)];
    [bezierPath addLineToPoint: CGPointMake(0.54, 11.21)];
    [bezierPath addLineToPoint: CGPointMake(1.64, 10.11)];
    [bezierPath addLineToPoint: CGPointMake(11.98, 19.9)];
    [bezierPath closePath];
    [bezierPath setLineWidth:1.0];
    [bezierPath fill];
    [bezierPath stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.viewControllers = [super viewControllers];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass
                              toolbarClass:(Class)toolbarClass
{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:TFYSafeWrapViewController(rootViewController, rootViewController.tfy_navigationBarClass)];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:[[TFYContainerController alloc] initWithContentController:rootViewController]];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [super setDelegate:self];
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if (viewController == nil) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
        return;
    }
    if(self.viewControllers.count != 0){
        viewController.hidesBottomBarWhenPushed = YES;
        self.tabBarController.tabBar.hidden = YES;
    }
    if (self.viewControllers.count > 0) {
        UIViewController *currentLast = TFYSafeUnwrapViewController(self.viewControllers.lastObject);
        [super pushViewController:TFYSafeWrapViewController(viewController,
                                                           viewController.tfy_navigationBarClass,
                                                           self.useSystemBackBarButtonItem,
                                                           currentLast.navigationItem.backBarButtonItem,
                                                           currentLast.navigationItem.title ?: currentLast.title)
                         animated:animated];
    }
    else {
        [super pushViewController:TFYSafeWrapViewController(viewController, viewController.tfy_navigationBarClass)
                         animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return TFYSafeUnwrapViewController([super popViewControllerAnimated:animated]);
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (@available(iOS 14.0, *)) {
        for (UIViewController *vc in self.viewControllers) {
            vc.hidesBottomBarWhenPushed = NO;
            self.tabBarController.tabBar.hidden = NO;
        }
    }
    return [[super popToRootViewControllerAnimated:animated] tfy_map:^id(__kindof UIViewController *obj, NSUInteger index) {
        return TFYSafeUnwrapViewController(obj);
    }];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                     animated:(BOOL)animated
{
    __block UIViewController *controllerToPop = nil;
    [[super viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        if (TFYSafeUnwrapViewController(obj) == viewController) {
            controllerToPop = obj;
            *stop = YES;
        }
    }];
    if (controllerToPop) {
        return [[super popToViewController:controllerToPop
                                  animated:animated] tfy_map:^id(__kindof UIViewController * obj, __unused NSUInteger index) {
            return TFYSafeUnwrapViewController(obj);
        }];
    }
    return nil;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
                  animated:(BOOL)animated
{
    [super setViewControllers:[viewControllers tfy_map:^id(__kindof UIViewController * obj,  NSUInteger index) {
        if (self.useSystemBackBarButtonItem && index > 0) {
            return TFYSafeWrapViewController(obj,
                                            obj.tfy_navigationBarClass,
                                            self.useSystemBackBarButtonItem,
                                            viewControllers[index - 1].navigationItem.backBarButtonItem,
                                            viewControllers[index - 1].title);
        }
        else
            return TFYSafeWrapViewController(obj, obj.tfy_navigationBarClass);
    }]
                     animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    self.tfy_delegate = delegate;
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return [self.tfy_delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.tfy_delegate;
}

#pragma mark - Public Methods

- (UIViewController *)tfy_topViewController
{
    return TFYSafeUnwrapViewController([super topViewController]);
}

- (UIViewController *)tfy_visibleViewController
{
    return TFYSafeUnwrapViewController([super visibleViewController]);
}

- (NSArray <__kindof UIViewController *> *)tfy_viewControllers
{
    return [[super viewControllers] tfy_map:^id(id obj, __unused NSUInteger index) {
        return TFYSafeUnwrapViewController(obj);
    }];
}

- (void)removeViewController:(UIViewController *)controller
{
    [self removeViewController:controller animated:NO];
}

- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag
{
    NSMutableArray<__kindof UIViewController *> *controllers = [self.viewControllers mutableCopy];
    __block UIViewController *controllerToRemove = nil;
    [controllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        if (TFYSafeUnwrapViewController(obj) == controller) {
            controllerToRemove = obj;
            *stop = YES;
        }
    }];
    if (controllerToRemove) {
        [controllers removeObject:controllerToRemove];
        [super setViewControllers:[NSArray arrayWithArray:controllers] animated:flag];
    }
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                  complete:(void (^)(BOOL))block
{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    [self pushViewController:viewController
                    animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void (^)(BOOL))block
{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    
    UIViewController *vc = [self popViewControllerAnimated:animated];
    if (!vc) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return vc;
}

- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                      animated:(BOOL)animated
                                                      complete:(void (^)(BOOL))block
{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    NSArray <__kindof UIViewController *> *array = [self popToViewController:viewController
                                                                    animated:animated];
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
                                                                  complete:(void (^)(BOOL))block
{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    
    NSArray <__kindof UIViewController *> *array = [self popToRootViewControllerAnimated:animated];
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    viewController = TFYSafeUnwrapViewController(viewController);
    if (!isRootVC && viewController.isViewLoaded) {
        
        BOOL hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil;
        if (hasSetLeftItem && !viewController.tfy_hasSetInteractivePop) {
            viewController.tfy_disableInteractivePop = YES;
        }
        else if (!viewController.tfy_hasSetInteractivePop) {
            viewController.tfy_disableInteractivePop = NO;
        }
        [self _installsLeftBarButtonItemIfNeededForViewController:viewController];
    }
    
    if ([self.tfy_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.tfy_delegate navigationController:navigationController
                        willShowViewController:viewController
                                      animated:animated];
    }
    
    /// 监听侧边滑动返回的事件
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *)) {
        [viewController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf handleSideSlideReturnIfNeeded:context];
        }];
    }
}

- (void)handleSideSlideReturnIfNeeded:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if (context.isCancelled) {
        return;
    }
    UIViewController *fromVc = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([self.uiNaviDelegate respondsToSelector:@selector(navigationControllerDidSideSlideReturn:fromViewController:)]) {
        [self.uiNaviDelegate navigationControllerDidSideSlideReturn:self fromViewController:fromVc];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    viewController = TFYSafeUnwrapViewController(viewController);
    if (!animated) {
        [viewController view];
    }
    if (viewController.tfy_disableInteractivePop) {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
    } else {
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = !isRootVC;
    }

    [TFY_NavigationController attemptRotationToDeviceOrientation];

    if ([self.tfy_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.tfy_delegate navigationController:navigationController
                         didShowViewController:viewController
                                      animated:animated];
    }
    
    if (self.animationBlock) {
        if (animated) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.animationBlock) {
                    self.animationBlock(YES);
                    self.animationBlock = nil;
                }
            });
        }
        else {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    
    if ([self.tfy_delegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.tfy_delegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController
{
    
    if ([self.tfy_delegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.tfy_delegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    if ([self.tfy_delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.tfy_delegate navigationController:navigationController
          interactionControllerForAnimationController:animationController];
    }
    if ([animationController respondsToSelector:@selector(tfy_interactiveTransitioning)]) {
        return [((id <TFYViewControllerAnimatedTransitioning>)animationController) tfy_interactiveTransitioning];
    }
    return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    if ([self.tfy_delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.tfy_delegate navigationController:navigationController
                      animationControllerForOperation:operation
                                   fromViewController:TFYSafeUnwrapViewController(fromVC)
                                     toViewController:TFYSafeUnwrapViewController(toVC)];
    }
    return operation == UINavigationControllerOperationPush ? [toVC tfy_animatedTransitioning] : [fromVC tfy_animatedTransitioning];
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}


@end
