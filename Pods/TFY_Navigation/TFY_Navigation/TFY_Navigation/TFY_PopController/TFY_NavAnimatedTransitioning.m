//
//  TFY_NavAnimatedTransitioning.m
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_NavAnimatedTransitioning.h"

@implementation TFY_NavAnimatedTransitioning

- (instancetype)initWithState:(PopState)state {
    self = [super init];
    if (self) {
        _state = state;
    }

    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.15;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.state == PopStatePop) {
        CGRect f = [transitionContext finalFrameForViewController:toVC];
        toVC.view.frame = f;
        [transitionContext.containerView insertSubview:toVC.view aboveSubview:fromVC.view];
    } else {
        [transitionContext.containerView insertSubview:toVC.view belowSubview:fromVC.view];
    }
    fromVC.view.alpha = 1;
    toVC.view.alpha = 0;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        fromVC.view.alpha = 0;
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        fromVC.view.alpha = 1;
    }];

}

@end
