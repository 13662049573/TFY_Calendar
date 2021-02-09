//
//  UINavigationController+TFYCategory.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBarButtonItem+TFYCategory.h"
#import "TFYDelegateHandler.h"
#import "TFYCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (TFYCategory)

/** 导航栏转场时是否缩放,此属性只能在初始化导航栏的时候有效，在其他地方设置会导致错乱 */
@property (nonatomic, assign) BOOL tfy_translationScale;

/** 是否开启左滑push操作，默认是NO，此时不可禁用控制器的滑动返回手势 */
@property (nonatomic, assign) BOOL tfy_openScrollLeftPush;

/** 是否禁止导航控制器的手势处理，默认NO，如果设置为YES，则手势操作将失效(包括全屏手势和边缘手势) */
@property (nonatomic, assign) BOOL tfy_disabledGestureHandle;
/**
 * 导航栏标题字体颜色
 */
@property (nonatomic, strong) UIColor *tfy_titleColor;
/**
 * 导航栏标题字号
 */
@property (nonatomic, strong) UIFont *tfy_titleFont;
/**
 * 导航栏背景色
 */
@property (nonatomic, strong) UIColor *tfy_barBackgroundColor;
/**
 * 导航栏背景图片
 */
@property (nonatomic, strong) UIImage *tfy_barBackgroundImage;
/**
 *  导航栏左侧返回按钮背景图片
 */
@property (nonatomic, strong) UIImage *tfy_barReturnButtonImage;
/**
 * 导航栏左侧返回按钮背景颜色
 */
@property (nonatomic, strong) UIColor *tfy_barReturnButtonColor;

/** 设置导航栏分割线颜色或图片 */
@property (nonatomic, strong) UIColor *tfy_navShadowColor;
@property (nonatomic, strong) UIImage *tfy_navShadowImage;

// 是否隐藏导航栏分割线，默认为NO
@property (nonatomic, assign) BOOL  tfy_navLineHidden;

/** 设置导航栏的透明度 */
@property (nonatomic, assign) CGFloat tfy_navBarAlpha;
/**
 * 设置导航栏完全透明  会设置translucent = YES
 */
- (void)tfy_navigationBarTransparent;
/**
 * 让导航栏完全不透明 会设置translucent = NO
 */
- (void)tfy_navigationBarOpaque;
/**
 *  当用户滑动时，导航控制器的导航栏和工具栏将被隐藏(向上滑动)或显示(向下滑动)。工具栏只有在拥有项时才参与。
 */
- (void)tfy_hidesNavigationBarsOnSwipe;
/**
   当用户点击时，导航控制器的导航栏和工具栏将会隐藏或显示，这取决于导航栏的隐藏状态。工具栏只有在有要显示的项目时才会显示。
 */
- (void)tfy_hidesBarsOnTap;

@end

NS_ASSUME_NONNULL_END
