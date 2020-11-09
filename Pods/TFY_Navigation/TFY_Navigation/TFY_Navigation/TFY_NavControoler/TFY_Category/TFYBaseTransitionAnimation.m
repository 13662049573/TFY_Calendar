//
//  TFYBaseTransitionAnimation.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFYBaseTransitionAnimation.h"
#import <objc/runtime.h>

@implementation TFYBaseTransitionAnimation

- (instancetype)initWithScale:(BOOL)scale {
    if (self = [super init]) {
        self.scale = scale;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

// 转场动画的时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return UINavigationControllerHideShowBarDuration;
}

// 转场动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 获取转场容器
    UIView *containerView = [transitionContext containerView];
    
    // 获取转场前后的控制器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.containerView      = containerView;
    self.fromViewController = fromVC;
    self.toViewController   = toVC;
    self.transitionContext  = transitionContext;
    
    [self animateTransition];
}

- (NSTimeInterval)animationDuration {
    return [self transitionDuration:self.transitionContext];
}

// 子类重写
- (void)animateTransition{}

- (void)completeTransition {
    [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
}

- (UIImage *)getCaptureWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

static const void* TFYCaptureImageKey = @"TFYCaptureImage";

@implementation UIViewController (GKCapture)

- (void)setTfy_captureImage:(UIImage *)tfy_captureImage {
    objc_setAssociatedObject(self, &TFYCaptureImageKey, tfy_captureImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)tfy_captureImage{
    return objc_getAssociatedObject(self, &TFYCaptureImageKey);
}
@end
