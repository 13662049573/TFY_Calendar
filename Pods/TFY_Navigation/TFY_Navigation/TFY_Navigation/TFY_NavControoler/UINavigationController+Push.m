//
//  UINavigationController+Push.m
//  Push
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import "UINavigationController+Push.h"
#import <objc/runtime.h>

static void tfy_swizzle_selector(Class cls, SEL origin, SEL swizzle) {
    method_exchangeImplementations(class_getInstanceMethod(cls, origin),
                                   class_getInstanceMethod(cls, swizzle));
}


@interface TFYNavigationPushTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

@interface TFYNavigationDelegater : NSObject <UINavigationControllerDelegate>
@property (nonatomic, weak) UINavigationController *navigationController;
+ (instancetype)delegaterWithNavigationController:(UINavigationController *)navigation;
@end

@implementation UINavigationController (Push)

- (void)tfy_viewDidLoad
{
    [self tfy_viewDidLoad];

    if (self.tfy_isInteractivePushEnabled) {
        [self tfy_setupInteractivePush];
    }
}

- (void)setTfy_originDelegate:(id<UINavigationControllerDelegate>)delegate
{
    objc_setAssociatedObject(self, @selector(tfy_originDelegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UINavigationControllerDelegate>)tfy_originDelegate
{
    return objc_getAssociatedObject(self, @selector(tfy_originDelegate));
}

#pragma mark - Methods

- (void)_setTransitionDelegate:(id<UINavigationControllerDelegate>)delegate
{
    objc_setAssociatedObject(self, @selector(_setTransitionDelegate:), delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.tfy_originDelegate = self.delegate;

    void (*setDelegate)(id, SEL, id<UINavigationControllerDelegate>) = (void(*)(id, SEL, id<UINavigationControllerDelegate>))[UINavigationController instanceMethodForSelector:@selector(setDelegate:)];
    if (setDelegate) {
        setDelegate(self, @selector(setDelegate:), delegate);
    }
}

- (void)tfy_setupInteractivePush
{
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(tfy_onPushGesture:)];
    pan.edges = UIRectEdgeRight;
    [pan requireGestureRecognizerToFail:self.interactivePopGestureRecognizer];
    [self.view addGestureRecognizer:pan];

    self.tfy_interactivePushGestureRecognizer = pan;
}

- (void)tfy_distroyInteractivePush
{
    [self.view removeGestureRecognizer:self.tfy_interactivePushGestureRecognizer];
    self.tfy_interactivePushGestureRecognizer = nil;
    [self _setTransitionDelegate:nil];

    void (*setDelegate)(id, SEL, id<UINavigationControllerDelegate>) = (void(*)(id, SEL, id<UINavigationControllerDelegate>))[UINavigationController instanceMethodForSelector:@selector(setDelegate:)];
    if (setDelegate) {
        setDelegate(self, @selector(setDelegate:), self.tfy_originDelegate);
    }

    self.tfy_originDelegate = nil;
}

- (void)tfy_onPushGesture:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            UIViewController *nextSiblingController = [self.topViewController tfy_nextSiblingController];
            if (nextSiblingController) {
                [self _setTransitionDelegate:[TFYNavigationDelegater delegaterWithNavigationController:self]];
                [self pushViewController:nextSiblingController
                                animated:YES];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gesture translationInView:gesture.view];
            CGFloat ratio = -translation.x / self.view.bounds.size.width;
            ratio = MAX(0, MIN(1, ratio));
            [self.tfy_interactiveTransition updateInteractiveTransition:ratio];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint velocity = [gesture velocityInView:gesture.view];

            if (velocity.x < -200) {
                [self.tfy_interactiveTransition finishInteractiveTransition];
            }
            else if (velocity.x > 200) {
                [self.tfy_interactiveTransition cancelInteractiveTransition];
            }
            else if (self.tfy_interactiveTransition.percentComplete > 0.5) {
                [self.tfy_interactiveTransition finishInteractiveTransition];
            }
            else {
                [self.tfy_interactiveTransition cancelInteractiveTransition];
            }
        }
            break;
        default:
            break;
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return nil;
}

#pragma mark - Properties

- (BOOL)tfy_isInteractivePushEnabled
{
    return [objc_getAssociatedObject(self, @selector(setTfy_enableInteractivePush:)) boolValue];
}

- (void)setTfy_enableInteractivePush:(BOOL)enableInteractivePush
{
    BOOL enabled = self.tfy_isInteractivePushEnabled;
    if (enabled != enableInteractivePush) {
        objc_setAssociatedObject(self, @selector(setTfy_enableInteractivePush:), @(enableInteractivePush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        if (self.isViewLoaded) {
            if (enableInteractivePush) {
                [self tfy_setupInteractivePush];
            }
            else {
                [self tfy_distroyInteractivePush];
            }
        }
        else {
            tfy_swizzle_selector(self.class, @selector(viewDidLoad), @selector(tfy_viewDidLoad));
        }
    }
}

- (void)setTfy_interactivePushGestureRecognizer:(UIPanGestureRecognizer * _Nullable)interactivePushGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(tfy_interactivePushGestureRecognizer), interactivePushGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPanGestureRecognizer *)tfy_interactivePushGestureRecognizer
{
    return objc_getAssociatedObject(self, @selector(tfy_interactivePushGestureRecognizer));
}

- (UIPercentDrivenInteractiveTransition *)tfy_interactiveTransition
{
    UIPercentDrivenInteractiveTransition *percent = objc_getAssociatedObject(self, @selector(tfy_interactiveTransition));
    if (!percent) {
        percent = [[UIPercentDrivenInteractiveTransition alloc] init];
        objc_setAssociatedObject(self, @selector(tfy_interactiveTransition), percent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return percent;
}

@end


@implementation UIViewController (Push)

- (nullable __kindof UIViewController *)tfy_nextSiblingController
{
    return nil;
}

@end



@implementation TFYNavigationDelegater

+ (instancetype)delegaterWithNavigationController:(UINavigationController *)navigation
{
    TFYNavigationDelegater *delegater = [[self alloc] init];
    delegater.navigationController = navigation;
    return delegater;
}


- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [self.navigationController.tfy_originDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.navigationController.tfy_originDelegate respondsToSelector:aSelector]) {
        return self.navigationController.tfy_originDelegate;
    }
    return nil;
}

#pragma mark - UINavigationController Delegate

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    id <UIViewControllerInteractiveTransitioning> transitioning = nil;
    if ([self.navigationController.tfy_originDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        transitioning = [self.navigationController.tfy_originDelegate navigationController:navigationController
                                              interactionControllerForAnimationController:animationController];
    }

    if (!transitioning && self.navigationController.tfy_interactivePushGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        transitioning = self.navigationController.tfy_interactiveTransition;
    }
    return transitioning;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    id <UIViewControllerAnimatedTransitioning> transitioning = nil;
    if ([self.navigationController.tfy_originDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        transitioning = [self.navigationController.tfy_originDelegate navigationController:navigationController
                                                          animationControllerForOperation:operation
                                                                       fromViewController:fromVC
                                                                         toViewController:toVC];
    }
    if (!transitioning) {
        if (operation == UINavigationControllerOperationPush && self.navigationController.tfy_interactivePushGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            transitioning = [[TFYNavigationPushTransition alloc] init];
        }
    }
    return transitioning;
}

@end


@implementation TFYNavigationPushTransition

- (UIImage *)shadowImage __attribute((const))
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(9, 1), NO, 0);

    const CGFloat locations[] = {0.f, 1.f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)@[(__bridge id)[UIColor clearColor].CGColor,
                                                                                  (__bridge id)[UIColor colorWithWhite:24.f/255
                                                                                                                 alpha:7.f/33].CGColor], locations);
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, CGPointZero, CGPointMake(9, 0), 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();

    return image;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return UINavigationControllerHideShowBarDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView    = [transitionContext containerView];

    fromVC.view.transform = CGAffineTransformIdentity;

    UIView *wrapperView         = [[UIView alloc] initWithFrame:containerView.bounds];
    UIImageView *shadowView     = [[UIImageView alloc] initWithFrame:CGRectMake(-9, 0, 9, wrapperView.frame.size.height)];
    shadowView.alpha            = 0.f;
    shadowView.image            = [self shadowImage];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [wrapperView addSubview:shadowView];

    [containerView addSubview:wrapperView];

    toVC.view.frame = wrapperView.bounds;
    [wrapperView addSubview:toVC.view];

    wrapperView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(containerView.bounds), 0);

    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:[transitionContext isInteractive] ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        fromVC.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(containerView.bounds) * 112 / 375, 0);
                        wrapperView.transform = CGAffineTransformIdentity;
                        shadowView.alpha      = 1.f;
                    }
                    completion:^(BOOL finished) {
                        if (finished) {
                            fromVC.view.transform                         = CGAffineTransformIdentity;

                            void (*setDelegate)(id, SEL, id<UINavigationControllerDelegate>) = (void(*)(id, SEL, id<UINavigationControllerDelegate>))[UINavigationController instanceMethodForSelector:@selector(setDelegate:)];
                            if (setDelegate) {
                                setDelegate(fromVC.navigationController, @selector(setDelegate:), fromVC.navigationController.tfy_originDelegate);
                            }

                            fromVC.navigationController.tfy_originDelegate = nil;

                            [containerView addSubview:toVC.view];
                            [wrapperView removeFromSuperview];
                        }
                        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                    }];
}

@end
