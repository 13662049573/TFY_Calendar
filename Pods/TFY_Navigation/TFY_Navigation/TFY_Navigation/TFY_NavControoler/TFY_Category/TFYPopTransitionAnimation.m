//
//  TFYPopTransitionAnimation.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFYPopTransitionAnimation.h"
#import "TFYCommon.h"

@implementation TFYPopTransitionAnimation

- (void)animateTransition {
    [self.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    // 是否隐藏tabbar
    self.isHideTabBar = self.toViewController.tabBarController && self.fromViewController.hidesBottomBarWhenPushed && self.toViewController.tfy_captureImage;
    __block UIView *toView = nil;
    
    if (self.isHideTabBar) {
        UIImageView *captureView = [[UIImageView alloc] initWithImage:self.toViewController.tfy_captureImage];
        captureView.frame = CGRectMake(0, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
        [self.containerView insertSubview:captureView belowSubview:self.fromViewController.view];
        toView = captureView;
        self.toViewController.view.hidden = YES;
        self.toViewController.tabBarController.tabBar.hidden = YES;
    }else {
        toView = self.toViewController.view;
    }
    self.contentView = toView;
    
    if (self.scale) {
        // 初始化阴影图层
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        [toView addSubview:self.shadowView];
        
        if (@available(iOS 11.0, *)) {
            CGRect frame = toView.frame;
            frame.origin.x     = TFY_Configure.tfy_translationX;
            frame.origin.y     = TFY_Configure.tfy_translationY;
            frame.size.height -= 2 * TFY_Configure.tfy_translationY;
            
            toView.frame = frame;
        }else {
            toView.transform = CGAffineTransformMakeScale(TFY_Configure.tfy_scaleX, TFY_Configure.tfy_scaleY);
        }
    }else {
        self.fromViewController.view.frame = CGRectMake(- (0.3 * TFY_SCREEN_WIDTH), 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
    }
    
    // 添加阴影
    self.fromViewController.view.layer.shadowColor   = [[UIColor blackColor] CGColor];
    self.fromViewController.view.layer.shadowOpacity = 0.2;
    self.fromViewController.view.layer.shadowRadius  = 4;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        
        self.fromViewController.view.frame = CGRectMake(TFY_SCREEN_WIDTH, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
        
        if (@available(iOS 11.0, *)) {
            toView.frame = CGRectMake(0, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
        }else {
            toView.transform = CGAffineTransformIdentity;
        }
    }completion:^(BOOL finished) {
        [self completeTransition];
        if (self.isHideTabBar) {
            [self.contentView removeFromSuperview];
            self.contentView = nil;
            
            self.toViewController.view.hidden = NO;
            if (self.toViewController.navigationController.childViewControllers.count == 1) {
                self.toViewController.tabBarController.tabBar.hidden = NO;
            }
        }
        [self.shadowView removeFromSuperview];
    }];
}

@end
