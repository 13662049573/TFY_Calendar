//
//  TFYPushTransitionAnimation.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFYPushTransitionAnimation.h"
#import "TFYCommon.h"

@implementation TFYPushTransitionAnimation

- (void)animateTransition {
    // 解决UITabBarController左滑push时的显示问题
    self.isHideTabBar = self.fromViewController.tabBarController && self.toViewController.hidesBottomBarWhenPushed;
    
    __block UIView *fromView = nil;
    
    if (self.isHideTabBar) {
        // 获取fromVC的截图
        UIImage *captureImage = [self getCaptureWithView:self.fromViewController.view.window];
        UIImageView *captureView = [[UIImageView alloc] initWithImage:captureImage];
        captureView.frame = CGRectMake(0, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
        [self.containerView addSubview:captureView];
        fromView = captureView;
        self.fromViewController.tfy_captureImage = captureImage;
        self.fromViewController.view.hidden = YES;
        self.fromViewController.tabBarController.tabBar.hidden = YES;
    }else {
        fromView = self.fromViewController.view;
    }
    self.contentView = fromView;
    
    [self.containerView addSubview:self.toViewController.view];
    
    // 设置转场前的frame
    self.toViewController.view.frame = CGRectMake(TFY_SCREEN_WIDTH, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
    
    if (self.scale) {
        // 初始化阴影并添加
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [fromView addSubview:self.shadowView];
    }
    
    self.toViewController.view.layer.shadowColor   = [[UIColor blackColor] CGColor];
    self.toViewController.view.layer.shadowOpacity = 0.2;
    self.toViewController.view.layer.shadowRadius  = 4;
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        if (self.scale) {
            if (@available(iOS 11.0, *)) {
                CGRect frame = fromView.frame;
                frame.origin.x     = TFY_Configure.tfy_translationX;
                frame.origin.y     = TFY_Configure.tfy_translationY;
                frame.size.height -= 2 * TFY_Configure.tfy_translationY;
                
                fromView.frame = frame;
            }else {
                fromView.transform = CGAffineTransformMakeScale(TFY_Configure.tfy_scaleX, TFY_Configure.tfy_scaleY);
            }
        }else {
            fromView.frame = CGRectMake(- (0.3 * TFY_SCREEN_WIDTH), 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
        }
        
        self.toViewController.view.frame = CGRectMake(0, 0, TFY_SCREEN_WIDTH, TFY_SCREEN_HEIGHT);
    }completion:^(BOOL finished) {
        [self completeTransition];
        if (self.isHideTabBar) {
            [self.contentView removeFromSuperview];
            self.contentView = nil;
            
            self.fromViewController.view.hidden = NO;
            if (self.fromViewController.navigationController.childViewControllers.count == 1) {
                self.fromViewController.tabBarController.tabBar.hidden = NO;
            }
        }
        [self.shadowView removeFromSuperview];
    }];
}
@end
