//
//  UIApplication+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFY_Scene.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (TFY_Tools)
/**
 * statusBar的frame
 */
+ (CGRect)tfy_statusBarFrame;

/**
 * 当前的windowScene
 */
+ (id)tfy_currentScene;

/**
 * 当前windowSceneDelegate
 */
+ (id)tfy_currentSceneDelegate;

/**
 * 最上面的window
 */
+ (UIWindow *)tfy_currentWindow;

/**
 * 当前关键视图
 */
+ (UIWindow *)tfy_currentKeyWindow;

/**
 * 当前操作的window
 */
+ (UIWindow *)tfy_window;

+ (UIWindow *)tfy_keyWindow;

/**
 * app的 delegate
 */
+ (id<UIApplicationDelegate>)delegate;

/**
 * 跟控制器-- window
 */
+ (__kindof UIViewController *)rootViewController;


@property (nonatomic, assign, class, readonly) BOOL tfy_isSceneApp;
/**
 * 最上层的非TabbarController和NavigationBarController的控制器
 */
+ (__kindof  UIViewController *)currentTopViewController;

+ (__kindof UINavigationController *)currentToNavgationController;

@end

@interface UIView (Navigation_Chain)

- (UINavigationController *_Nonnull)navigationController;

@end

NS_ASSUME_NONNULL_END
