//
//  UIViewController+TFYCategory.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFYCommon.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const TFYViewControllerPropertyChangedNotification;

// 交给单独控制器处理
// push代理
@protocol TFYViewControllerPushDelegate <NSObject>

@optional
- (void)pushToNextViewController;
@end

// pop代理
@protocol TFYViewControllerPopDelegate <NSObject>

@optional
- (void)viewControllerPopScrollBegan;
- (void)viewControllerPopScrollUpdate:(float)progress;
- (void)viewControllerPopScrollEnded;

@end


@interface UIViewController (TFYCategory)
/** 是否禁止当前控制器的滑动返回(包括全屏返回和边缘返回) */
@property (nonatomic, assign) BOOL tfy_interactivePopDisabled;

/** 是否禁止当前控制器的全屏滑动返回 */
@property (nonatomic, assign) BOOL tfy_fullScreenPopDisabled;

/** 全屏滑动时，滑动区域距离屏幕左边的最大位置，默认是0：表示全屏都可滑动 */
@property (nonatomic, assign) CGFloat tfy_popMaxAllowedDistanceToLeftEdge;

/** 设置导航栏的透明度 */
@property (nonatomic, assign) CGFloat tfy_navBarAlpha;

/** 设置状态栏类型 */
@property (nonatomic, assign) UIStatusBarStyle tfy_statusBarStyle;

/** 设置状态栏是否隐藏(default is NO 即不隐藏) */
@property (nonatomic, assign) BOOL tfy_statusBarHidden;

/** 自定义返回按钮图片 */
@property (nonatomic, strong) UIImage *tfy_backImage;

/** 设置返回按钮的类型 */
@property (nonatomic, assign) TFYNavigationBarBackStyle tfy_backStyle;

/** push代理 */
@property (nonatomic, weak) id<TFYViewControllerPushDelegate> tfy_pushDelegate;

/** pop代理，如果设置了gk_popDelegate，原来的滑动返回手势将失效 */
@property (nonatomic, weak) id<TFYViewControllerPopDelegate> tfy_popDelegate;

/** 自定义push转场动画 */
@property (nonatomic, weak) id<UIViewControllerAnimatedTransitioning> tfy_pushTransition;

/** 自定义pop转场动画 */
@property (nonatomic, weak) id<UIViewControllerAnimatedTransitioning> tfy_popTransition;

/** 导航栏左右按钮距离屏幕边缘的距离，需在设置左右item之前设置此属性 */
@property (nonatomic, assign) CGFloat tfy_navItemLeftSpace;
@property (nonatomic, assign) CGFloat tfy_navItemRightSpace;

// 获取当前controller里的最高层可见viewController（可见的意思是还会判断self.view.window是否存在）
- (UIViewController *)tfy_visibleViewControllerIfExist;

@end

NS_ASSUME_NONNULL_END
