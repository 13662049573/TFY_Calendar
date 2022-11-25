//
//  TFY_NavigationController.h
//  TFY_NavigationController
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+Push.h"
#import "UIViewController+RootNavigation.h"
#import "TFYViewControllerAnimatedTransitioning.h"

@interface TFYContainerController : UIViewController
@property (nonatomic, readonly, strong) __kindof UIViewController * _Nullable contentViewController;
@end

@interface TFYContainerNavigationController : UINavigationController
@end

NS_ASSUME_NONNULL_BEGIN

@class TFY_NavigationController;
@protocol TFYNavigationControllerDelegate <NSObject>
@optional
/// 点击返回按钮调用
- (void)navigationControllerDidClickLeftButton:(TFY_NavigationController *)controller;
/// 侧滑划出控制器调用
- (void)navigationControllerDidSideSlideReturn:(TFY_NavigationController *)controller
                            fromViewController:(UIViewController *)fromViewController;
@end

IB_DESIGNABLE
@interface TFY_NavigationController : UINavigationController

@property (nonatomic, weak) id<TFYNavigationControllerDelegate> uiNaviDelegate;
/*!
 *  使用系统原始的背栏项目或自定义背栏项目返回
 */
@property (nonatomic, assign) IBInspectable BOOL useSystemBackBarButtonItem;

/// 天气每个单独的导航栏使用根导航栏的视觉样式。默认为
@property (nonatomic, assign) IBInspectable BOOL transferNavigationBarAttributes;

/*!
 *  使用这个属性而不是 visibleViewController来获取当前可见的内容视图控制器
 */
@property (nonatomic, readonly, strong) UIViewController *tfy_visibleViewController;

/*!
 *  使用这个属性而不是 topViewController来获得堆栈顶部的内容视图控制器
 */
@property (nonatomic, readonly, strong) UIViewController *tfy_topViewController;

/*!
 *  使用这个属性获取所有的内容视图控制器;
 */
@property (nonatomic, readonly, strong) NSArray <__kindof UIViewController *> *tfy_viewControllers;

/**
 *  使用根视图控制器初始化，而不封装到导航控制器中 rootViewController根视图控制器
 */
- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController;

/*!
 *  从堆栈中移除一个内容视图控制器
 *
 */
- (void)removeViewController:(UIViewController *)controller NS_REQUIRES_SUPER;
- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag NS_REQUIRES_SUPER;

/*!
 *  当动画完成时，Push一个视图控制器并做某事
 */
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                  complete:(void(^)(BOOL finished))block;

/*!
 *  用一个完整的处理程序在顶部弹出当前视图控制器
 *
 */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;

/*!
 *  弹出到一个带有完整处理器的特定视图控制器
 */
- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                      animated:(BOOL)animated
                                                      complete:(void(^)(BOOL finished))block;

/*!
 *  弹出根视图控制器与一个完整的处理程序
 *
 */
- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
                                                                  complete:(void(^)(BOOL finished))block;


@end

NS_ASSUME_NONNULL_END
