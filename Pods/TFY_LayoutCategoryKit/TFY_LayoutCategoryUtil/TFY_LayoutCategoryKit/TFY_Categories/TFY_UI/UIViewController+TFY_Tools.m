//
//  UIViewController+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIViewController+TFY_Tools.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface TFYPopPresentAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter=isPresentation) BOOL presentation;
@property (nonatomic,assign)TFYPopDirection direction;

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@property(nonatomic , strong)UIViewController *fromVC;

@end

@implementation TFYPopPresentAnimation

+(instancetype)presentAnimationWithDirection:(TFYPopDirection)direction isPresentation:(BOOL)isPresentation
{
    TFYPopPresentAnimation * presentAnimation = [[TFYPopPresentAnimation alloc] init];
    presentAnimation.direction = direction;
    presentAnimation.presentation = isPresentation;
    return presentAnimation;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //1
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromVC = fromVC;
    //2
    CGRect backRect = transitionContext.containerView.bounds;
    if (self.presentation && toVC.view) {
        UIView * backView = [[UIView alloc] initWithFrame:backRect];
        backView.backgroundColor = [UIColor blackColor];
        backView.alpha = 0.5;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:fromVC action:@selector(dismissViewController)];
        [backView addGestureRecognizer:tap];
        [[transitionContext containerView] addSubview:backView];
        [[transitionContext containerView] addSubview:toVC.view];
    }
   
    CGSize finalSize = self.presentation? toVC.preferredContentSize:fromVC.preferredContentSize;
    
    CGFloat final_X=0,final_Y=0;
    switch (self.direction) {
        case TFYPopDirectionCenter:
        {
            final_X = (CGRectGetWidth(backRect)-finalSize.width)/2.0;
            final_Y = (CGRectGetHeight(backRect)-finalSize.height)/2.0;
        }
            break;
        case TFYPopDirectionTop:
        {
            final_X = (CGRectGetWidth(backRect)-finalSize.width)/2.0;
            final_Y = 0;
        }
            break;
        case TFYPopDirectionLeft:
        {
            final_X = 0;
            final_Y = (CGRectGetHeight(backRect)-finalSize.height)/2.0;
        }
            break;
        case TFYPopDirectionRight:
        {
            final_X = (CGRectGetWidth(backRect)-finalSize.width);
            final_Y = (CGRectGetHeight(backRect)-finalSize.height)/2.0;
        }
            break;
        case TFYPopDirectionBottom:
        {
            final_X = (CGRectGetWidth(backRect)-finalSize.width)/2.0;
            final_Y = (CGRectGetHeight(backRect)-finalSize.height);
        }
            break;
            
        default:
            break;
    }
    CGRect finalRect = CGRectMake(final_X, final_Y, finalSize.width, finalSize.height);

    
    UIView * animationView = self.presentation?toVC.view:fromVC.view;
    NSInteger count = transitionContext.containerView.subviews.count;
    UIView *alphaView = transitionContext.containerView.subviews[count-2];
    alphaView.alpha = self.presentation?0:0.2;
    //3
    switch (self.direction) {
        case TFYPopDirectionCenter:
        {
            animationView.frame = self.presentation?CGRectOffset(finalRect, 0,[UIScreen mainScreen].bounds.size.height-final_Y):finalRect;
        }
            break;
        case TFYPopDirectionTop:
        {
            animationView.frame = self.presentation?CGRectOffset(finalRect, 0,finalSize.height*(-1)):finalRect;
        }
            break;
        case TFYPopDirectionLeft:
        {
            animationView.frame = self.presentation?CGRectOffset(finalRect, finalSize.width*(-1),0):finalRect;
        }
            break;
        case TFYPopDirectionRight:
        {
            animationView.frame = self.presentation?CGRectOffset(finalRect, finalSize.width,0):finalRect;
        }
            break;
        case TFYPopDirectionBottom:
        {
            animationView.frame = self.presentation?CGRectOffset(finalRect, 0, finalSize.height):finalRect;
        }
            break;
            
        default:
            break;
    }

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        switch (self.direction) {
            case TFYPopDirectionCenter:
            {
                animationView.frame = self.presentation?finalRect:CGRectOffset(finalRect, 0,[UIScreen mainScreen].bounds.size.height-final_Y);
            }
                break;
            case TFYPopDirectionTop:
            {
                animationView.frame = self.presentation?finalRect:CGRectOffset(finalRect, 0,finalSize.height*(-1));
            }
                break;
            case TFYPopDirectionLeft:
            {
                animationView.frame = self.presentation?finalRect:CGRectOffset(finalRect, finalSize.width*(-1),0);
            }
                break;
            case TFYPopDirectionRight:
            {
                animationView.frame = self.presentation?finalRect:CGRectOffset(finalRect, finalSize.width,0);
            }
                break;
            case TFYPopDirectionBottom:
            {
                animationView.frame = self.presentation?finalRect:CGRectOffset(finalRect, 0, finalSize.height);
            }
                break;
                
            default:
                break;
        }
        alphaView.alpha = self.presentation?0.2:0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)dismissViewController {
    [self.fromVC dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface TFYPopTransitionDelegate : NSObject<UIViewControllerTransitioningDelegate>

@property (nonatomic,assign)TFYPopDirection direction;

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;

@end

@implementation TFYPopTransitionDelegate

+(instancetype)transtionDelegateWithDirection:(TFYPopDirection)direction
{
    TFYPopTransitionDelegate * delegate = [[TFYPopTransitionDelegate alloc] init];
    delegate.direction = direction;
    return delegate;
}
-(nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
{
    return [TFYPopPresentAnimation presentAnimationWithDirection:self.direction isPresentation:YES];
}
-(nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [TFYPopPresentAnimation presentAnimationWithDirection:self.direction isPresentation:NO];
}

@end


@implementation UIViewController (TFY_Tools)

+ (void)load {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector= @selector(tfy_viewWillAppear:);

        Method originalMethod = class_getInstanceMethod(class,originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class,swizzledSelector);
        method_exchangeImplementations(originalMethod,swizzledMethod);

    });
}

- (void)tfy_viewWillAppear:(BOOL)animated {
    [self tfy_viewWillAppear:animated];
    UIScrollView *scrollView = nil;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]] || [view isKindOfClass:[UICollectionView class]]) {
            scrollView = (UIScrollView *)view;
            break;
        }
    }
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)tfy_setAutomaticallyAdjustsScrollViewInsets:(BOOL)automaticallyAdjustsScrollViewInsets {

    [self tfy_setAutomaticallyAdjustsScrollViewInsets:automaticallyAdjustsScrollViewInsets];

}

// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return YES;
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault; // your own style
}

- (BOOL)prefersStatusBarHidden {
    return NO; // your own visibility code
}

+ (UIViewController *)currentViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

- (void)presentViewController:(UIViewController *)viewController inSize:(CGSize)size direction:(TFYPopDirection)direction completion:(PresentCompletion)completion;
{
    if (!viewController) {
        return;
    }
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.preferredContentSize = size;
    TFYPopTransitionDelegate * transitionDelegate = [TFYPopTransitionDelegate transtionDelegateWithDirection:direction];
    viewController.transitioningDelegate = transitionDelegate;
    objc_setAssociatedObject(viewController, _cmd, transitionDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self presentViewController:viewController animated:YES completion:completion];
    
}

-(void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation UINavigationController (TFY_PlayerRotation)
/**
 * 如果window的根视图是UINavigationController，则会先调用这个Category，然后调用UIViewController+TFY_PlayerRotation
 * 只需要在支持除竖屏以外方向的页面重新下边三个方法
 */

// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end

@implementation UITabBarController (TFY_PlayerRotation)

+ (void)load {
    SEL selectors[] = {
        @selector(selectedIndex)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"tfy_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

- (NSInteger)tfy_selectedIndex {
    NSInteger index = [self tfy_selectedIndex];
    if (index > self.viewControllers.count) { return 0; }
    return index;
}

/**
 * 如果window的根视图是UITabBarController，则会先调用这个Category，然后调用UIViewController+ZFPlayerRotation
 * 只需要在支持除竖屏以外方向的页面重新下边三个方法
 */

// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController shouldAutorotate];
    } else {
        return [vc shouldAutorotate];
    }
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController supportedInterfaceOrientations];
    } else {
        return [vc supportedInterfaceOrientations];
    }
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.viewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController preferredInterfaceOrientationForPresentation];
    } else {
        return [vc preferredInterfaceOrientationForPresentation];
    }
}

@end

@implementation UIAlertController (TFY_PlayerRotation)

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations; {
    return UIInterfaceOrientationMaskAll;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif

@end
