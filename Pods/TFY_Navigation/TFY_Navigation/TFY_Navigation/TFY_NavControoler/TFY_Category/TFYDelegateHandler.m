//
//  TFYDelegateHandler.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFYDelegateHandler.h"
#import "TFYCommon.h"

@implementation TFYPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    UIViewController *visibleVC = self.navigationController.visibleViewController;
    
    if (self.navigationController.tfy_openScrollLeftPush) {
        // 开启了左滑push功能
    }else if (visibleVC.tfy_popDelegate) {
        // 设置了gk_popDelegate
    }else {
        // 忽略根控制器
        if (self.navigationController.viewControllers.count <= 1) return NO;
    }
    
    // 忽略禁用手势
    if (visibleVC.tfy_interactivePopDisabled) return NO;
    
    CGPoint transition = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    
    if (transition.x < 0) { // 左滑处理
        // 开启了左滑push并设置了代理
        if (self.navigationController.tfy_openScrollLeftPush && visibleVC.tfy_pushDelegate) {
            [gestureRecognizer removeTarget:self.systemTarget action:action];
            [gestureRecognizer addTarget:self.customTarget action:@selector(panGestureRecognizerAction:)];
        }else {
            return NO;
        }
    }else { // 右滑处理
        // 解决根控制器右滑时出现的卡死情况
        if (visibleVC.tfy_popDelegate) {
            // 实现了gk_popDelegate，不作处理
        }else {
            if (self.navigationController.viewControllers.count <= 1) return NO;
        }
        
        // 全屏滑动时起作用
        if (!visibleVC.tfy_fullScreenPopDisabled) {
            // 上下滑动
            if (transition.x == 0) return NO;
        }
        
        // 忽略超出手势区域
        CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        CGFloat maxAllowDistance  = visibleVC.tfy_popMaxAllowedDistanceToLeftEdge;
        
        if (maxAllowDistance > 0 && beginningLocation.x > maxAllowDistance) {
            return NO;
        }else if (visibleVC.tfy_popDelegate) {
            [gestureRecognizer removeTarget:self.systemTarget action:action];
            [gestureRecognizer addTarget:self.customTarget action:@selector(panGestureRecognizerAction:)];
        }else if(!self.navigationController.tfy_translationScale) { // 非缩放，系统处理
            [gestureRecognizer removeTarget:self.customTarget action:@selector(panGestureRecognizerAction:)];
            [gestureRecognizer addTarget:self.systemTarget action:action];
        }else {
            [gestureRecognizer removeTarget:self.systemTarget action:action];
            [gestureRecognizer addTarget:self.customTarget action:@selector(panGestureRecognizerAction:)];
        }
    }
    
    // 忽略导航控制器正在做转场动画
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) return NO;
    
    return YES;
}

@end

@interface TFYNavigationControllerDelegate()

@property (nonatomic, assign) BOOL isGesturePush;

// push动画的百分比
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *pushTransition;

// pop动画的百分比
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *popTransition;

@end

@implementation TFYNavigationControllerDelegate

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    if (fromVC.tfy_pushTransition && operation == UINavigationControllerOperationPush) {
        return fromVC.tfy_pushTransition;
    }
    
    if (fromVC.tfy_popTransition && operation == UINavigationControllerOperationPop) {
        return fromVC.tfy_popTransition;
    }
    
    if ((self.navigationController.tfy_translationScale) || (self.navigationController.tfy_openScrollLeftPush && self.pushTransition)) {
        if (operation == UINavigationControllerOperationPush) {
            return [[TFYPushTransitionAnimation alloc] initWithScale:self.navigationController.tfy_translationScale];
        }else if (operation == UINavigationControllerOperationPop) {
            return [[TFYPopTransitionAnimation alloc] initWithScale:self.navigationController.tfy_translationScale];
        }
    }
    
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ((self.navigationController.tfy_translationScale) || (self.navigationController.tfy_openScrollLeftPush && self.pushTransition)) {
        
        if ([animationController isKindOfClass:[TFYPopTransitionAnimation class]]) {
            return self.popTransition;
        }else if ([animationController isKindOfClass:[TFYPushTransitionAnimation class]]) {
            return self.pushTransition;
        }
    }
    
    return nil;
}

#pragma mark - 滑动手势处理
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)gesture {
    UIViewController *visibleVC = self.navigationController.visibleViewController;
    
    // 进度
    CGFloat progress    = [gesture translationInView:gesture.view].x / gesture.view.bounds.size.width;
    CGPoint translation = [gesture velocityInView:gesture.view];
    
    // 在手势开始的时候判断是push操作还是pop操作
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.isGesturePush = translation.x < 0 ? YES : NO;
    }
    
    // push时 progress < 0 需要做处理
    if (self.isGesturePush) {
        progress = -progress;
    }
    
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.isGesturePush) {
            if (self.navigationController.tfy_openScrollLeftPush) {
                if (visibleVC.tfy_pushDelegate && [visibleVC.tfy_pushDelegate respondsToSelector:@selector(pushToNextViewController)]) {
                    self.pushTransition = [UIPercentDrivenInteractiveTransition new];
                    self.pushTransition.completionCurve = UIViewAnimationCurveEaseOut;
                    [self.pushTransition updateInteractiveTransition:0];
                    
                    [visibleVC.tfy_pushDelegate pushToNextViewController];
                }
            }
        }else {
            if (visibleVC.tfy_popDelegate) {
                if ([visibleVC.tfy_popDelegate respondsToSelector:@selector(viewControllerPopScrollBegan)]) {
                    [visibleVC.tfy_popDelegate viewControllerPopScrollBegan];
                }
            }else {
                self.popTransition = [UIPercentDrivenInteractiveTransition new];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.isGesturePush) {
            if (self.pushTransition) {
                [self.pushTransition updateInteractiveTransition:progress];
            }
        }else {
            if (visibleVC.tfy_popDelegate) {
                if ([visibleVC.tfy_popDelegate respondsToSelector:@selector(viewControllerPopScrollUpdate:)]) {
                    [visibleVC.tfy_popDelegate viewControllerPopScrollUpdate:progress];
                }
            }else {
                [self.popTransition updateInteractiveTransition:progress];
            }
        }
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (self.isGesturePush) {
            if (self.pushTransition) {
                if (progress > TFY_Configure.tfy_pushTransitionCriticalValue) {
                    [self.pushTransition finishInteractiveTransition];
                }else {
                    [self.pushTransition cancelInteractiveTransition];
                }
            }
        }else {
            if (visibleVC.tfy_popDelegate) {
                if ([visibleVC.tfy_popDelegate respondsToSelector:@selector(viewControllerPopScrollEnded)]) {
                    [visibleVC.tfy_popDelegate viewControllerPopScrollEnded];
                }
            }else {
                if (progress > TFY_Configure.tfy_popTransitionCriticalValue) {
                    [self.popTransition finishInteractiveTransition];
                }else {
                    [self.popTransition cancelInteractiveTransition];
                }
            }
        }
        self.pushTransition = nil;
        self.popTransition  = nil;
        self.isGesturePush  = NO;
    }
}

@end

