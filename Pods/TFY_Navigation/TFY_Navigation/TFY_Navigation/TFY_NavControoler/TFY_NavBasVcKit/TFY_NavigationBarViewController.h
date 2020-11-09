//
//  TFY_NavigationBarViewController.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFYCommon.h"
#import "TFY_Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_NavigationBarViewController : UIViewController

// 自定义导航条
@property (nonatomic, strong, readonly) TFYNavigationBar     *tfy_navigationBar;

// 自定义导航条栏目
@property (nonatomic, strong, readonly) UINavigationItem    *tfy_navigationItem;

#pragma mark - 额外的快速设置导航栏的属性
@property (nonatomic, strong) UIColor                       *tfy_navBarTintColor;
@property (nonatomic, strong) UIColor                       *tfy_navBackgroundColor;
@property (nonatomic, strong) UIImage                       *tfy_navBackgroundImage;
/** 设置导航栏分割线颜色或图片 */
@property (nonatomic, strong) UIColor                       *tfy_navShadowColor;
@property (nonatomic, strong) UIImage                       *tfy_navShadowImage;

@property (nonatomic, strong) UIColor                       *tfy_navTintColor;
@property (nonatomic, strong) UIView                        *tfy_navTitleView;
@property (nonatomic, strong) UIColor                       *tfy_navTitleColor;
@property (nonatomic, strong) UIFont                        *tfy_navTitleFont;

@property (nonatomic, strong) UIBarButtonItem               *tfy_navLeftBarButtonItem;
@property (nonatomic, strong) NSArray<UIBarButtonItem *>    *tfy_navLeftBarButtonItems;

@property (nonatomic, strong) UIBarButtonItem               *tfy_navRightBarButtonItem;
@property (nonatomic, strong) NSArray<UIBarButtonItem *>    *tfy_navRightBarButtonItems;

/** 页面标题-快速设置 */
@property (nonatomic, copy) NSString                        *tfy_navTitle;

/// 是否隐藏导航栏分割线，默认为NO
@property (nonatomic, assign) BOOL                          tfy_navLineHidden;

/// 显示导航栏分割线
- (void)showNavLine;

/// 隐藏导航栏分割线
- (void)hideNavLine;

/// 刷新导航栏frame
- (void)refreshNavBarFrame;

@end

@interface UIViewController (NavigationBar)

/** 设置导航栏的透明度 */
@property (nonatomic, assign) CGFloat tfy_navBaseBarAlpha;

@end

NS_ASSUME_NONNULL_END
