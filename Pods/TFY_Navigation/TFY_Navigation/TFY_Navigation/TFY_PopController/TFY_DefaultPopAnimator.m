//
//  TFY_DefaultPopAnimator.m
//  TFY_Navigation
//
//  Created by 田风有 on 2019/11/2.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_DefaultPopAnimator.h"
#import "TFY_PopControllerAnimatedTransitioning.h"

static const CGFloat kDefaultSpringDamping = 0.8;
static const CGFloat kDefaultSpringVelocity = 10.0;

@implementation TFY_DefaultPopAnimator
- (NSTimeInterval)popControllerAnimationDuration:(PopAnimationContext *)context {
    return context.duration ?: 0.2;
}

- (void)popAnimate:(PopAnimationContext *)context completion:(void (^)(BOOL finished))completion {
    NSTimeInterval duration = [self popControllerAnimationDuration:context];
    UIView *containerView = context.containerView;
    switch (self.popType) {
        case PopTypeFadeIn:{
            containerView.transform = CGAffineTransformIdentity;
            containerView.alpha = 0;
            [UIView animateWithDuration:duration animations:^{
                containerView.alpha = 1;
            } completion:completion];
        }
            break;
        case PopTypeGrowIn:{
            containerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            containerView.alpha = 0;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.transform = CGAffineTransformIdentity;
                containerView.alpha = 1;
            } completion:completion];
        }
            break;
        case PopTypeShrinkIn:{
            containerView.alpha = 0;
            containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.alpha = 1;
                containerView.transform = CGAffineTransformIdentity;
            } completion:completion];
        }
            break;
        case PopTypeSlideInFromTop:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.y = -CGRectGetHeight(originFrame) - 20;
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        case PopTypeSlideInFromBottom:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.y = containerView.superview.frame.size.height;
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        case PopTypeSlideInFromLeft:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.x = -CGRectGetWidth(rect);
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        case PopTypeSlideInFromRight:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.x = CGRectGetWidth(containerView.superview.frame);
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        case PopTypeBounceIn:{
            containerView.transform = CGAffineTransformIdentity;
            containerView.alpha = 0;
            containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                containerView.alpha = 1;
                containerView.transform = CGAffineTransformIdentity;
            } completion:completion];
        }
            break;
        case PopTypeBounceInFromTop:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.y = -CGRectGetHeight(originFrame);
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        case PopTypeBounceInFromBottom:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.y = CGRectGetHeight(containerView.superview.frame);
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        case PopTypeBounceInFromLeft:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.x = -CGRectGetWidth(rect);
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        case PopTypeBounceInFromRight:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            CGRect originFrame = containerView.frame;
            CGRect rect = containerView.frame;
            rect.origin.x = CGRectGetWidth(containerView.superview.frame);
            containerView.frame = rect;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                containerView.frame = originFrame;
            } completion:completion];
        }
            break;
        default:{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
            completion ? completion(YES) : nil;
        }
            break;
    }
}

- (void)dismissAnimate:(PopAnimationContext *)context completion:(void (^)(BOOL finished))completion {
    NSTimeInterval duration = [self popControllerAnimationDuration:context];
    NSTimeInterval bounceDuration1 = duration * 1.f / 3.f;
    NSTimeInterval bounceDuration2 = duration * 2.f / 3.f;
    
    UIView *containerView = context.containerView;
    switch (self.dismissType) {
        case DismissTypeFadeOut:{
            containerView.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:duration animations:^{
                containerView.alpha = 0;
            } completion:completion];
        }
            break;
        case DismissTypeGrowOut:{
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                containerView.alpha = 0;
            } completion:completion];
        }
            break;
        case DismissTypeShrinkOut:{
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.alpha = 0;
                containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
            } completion:completion];
        }
            break;
        case DismissTypeSlideOutToTop:{
            CGRect rect = containerView.frame;
            rect.origin.y = -CGRectGetHeight(rect);
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = rect;
            } completion:completion];
        }
            break;
        case DismissTypeSlideOutToBottom:{
            CGRect rect = containerView.frame;
            rect.origin.y = containerView.superview.frame.size.height;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = rect;
            } completion:completion];
        }
            break;
        case DismissTypeSlideOutToLeft:{
            CGRect rect = containerView.frame;
            rect.origin.x = -CGRectGetWidth(rect);
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = rect;
            } completion:completion];
        }
            break;
        case DismissTypeSlideOutToRight:{
            CGRect rect = containerView.frame;
            rect.origin.x = CGRectGetWidth(containerView.superview.frame);
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerView.frame = rect;
            } completion:completion];
        }
            break;
        case DismissTypeBounceOut:{
            [UIView animateWithDuration:bounceDuration1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:bounceDuration2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    containerView.alpha = 0;
                    containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                } completion:completion];
            }];
        }
            break;
        case DismissTypeBounceOutToTop:{
            CGRect rect1 = containerView.frame;
            rect1.origin.y += 20;
            CGRect rect2 = containerView.frame;
            rect2.origin.y = -CGRectGetHeight(rect2);
            [UIView animateWithDuration:bounceDuration1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                containerView.frame = rect1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:bounceDuration2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    containerView.frame = rect2;
                } completion:completion];
            }];
        }
            break;
        case DismissTypeBounceOutToBottom:{
            CGRect rect1 = containerView.frame;
            rect1.origin.y -= 20;
            CGRect rect2 = containerView.frame;
            rect2.origin.y = CGRectGetHeight(containerView.superview.frame);
            [UIView animateWithDuration:bounceDuration1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                containerView.frame = rect1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:bounceDuration2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    containerView.frame = rect2;
                } completion:completion];
            }];
        }
            break;
        case DismissTypeBounceOutToLeft:{
            CGRect rect1 = containerView.frame;
            rect1.origin.x += 20;
            CGRect rect2 = containerView.frame;
            rect2.origin.x = -CGRectGetWidth(rect2);
            [UIView animateWithDuration:bounceDuration1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                containerView.frame = rect1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:bounceDuration2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    containerView.frame = rect2;
                } completion:completion];
            }];
        }
            break;
        case DismissTypeBounceOutToRight:{
            CGRect rect1 = containerView.frame;
            rect1.origin.x -= 20;
            CGRect rect2 = containerView.frame;
            rect2.origin.x = CGRectGetWidth(containerView.superview.frame);
            [UIView animateWithDuration:bounceDuration1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                containerView.frame = rect1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:bounceDuration2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    containerView.frame = rect2;
                } completion:completion];
            }];
        }
            break;
        default:{
            containerView.alpha = 0;
            containerView.transform = CGAffineTransformIdentity;
            completion ? completion(YES) : nil;
        }
            break;
    }
}

@end
