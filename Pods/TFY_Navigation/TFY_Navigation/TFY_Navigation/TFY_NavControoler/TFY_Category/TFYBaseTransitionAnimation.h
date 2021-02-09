//
//  TFYBaseTransitionAnimation.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFYBaseTransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL              scale;

@property (nonatomic, strong) UIView            *shadowView;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, weak) UIView              *containerView;

@property (nonatomic, weak) UIViewController    *fromViewController;

@property (nonatomic, weak) UIViewController    *toViewController;

@property (nonatomic, assign) BOOL              isHideTabBar;

@property (nonatomic, strong, nullable) UIView  *contentView;

// 初始化  是否需要缩放
- (instancetype)initWithScale:(BOOL)scale;

// 动画时间
- (NSTimeInterval)animationDuration;

// 动画
- (void)animateTransition;

// 完成动画
- (void)completeTransition;

// 获取某个view的截图
- (UIImage *)getCaptureWithView:(UIView *)view;

@end

@interface UIViewController (GKCapture)

@property (nonatomic, strong) UIImage *tfy_captureImage;

@end

NS_ASSUME_NONNULL_END
