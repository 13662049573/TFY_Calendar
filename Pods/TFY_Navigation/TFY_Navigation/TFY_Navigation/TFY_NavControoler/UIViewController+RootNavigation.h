//
//  UIViewController+RootNavigation.h
//  RootNavigation
//
//  Created by 田风有 on 2021/8/8.
//  Copyright © 2021 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFY_NavigationController;

@protocol TFYNavigationItemCustomizable <NSObject>

@optional

/**
 * 重写这个方法来提供一个自定义的back栏项，默认是一个普通的@c UIBarButtonItem带有标题@b " back "
 */
- (UIBarButtonItem *_Nullable)tfy_customBackItemWithTarget:(id _Nonnull )target action:(SEL _Nonnull )action;

@end

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface UIViewController (RootNavigation)<TFYNavigationItemCustomizable>
/*!
 * 设置此属性为@b YES以禁用交互式弹出
 */
@property (nonatomic, assign) IBInspectable BOOL tfy_disableInteractivePop;

/*!
 * navigationControlle将得到一个包装@c UINavigationController，使用这个属性来获得真正的导航控制器
 */
@property (nonatomic, readonly, strong) TFY_NavigationController *tfy_navigationController;

/*!
 *  覆盖这个方法以提供@c UINavigationBar的自定义子类，默认返回nil
 */
- (Class)tfy_navigationBarClass;

@property (nonatomic, readonly) id<UIViewControllerAnimatedTransitioning> tfy_animatedTransitioning;

@end

NS_ASSUME_NONNULL_END
