//
//  TFYNavigationBarConfigure.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/25.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFYCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFYNavigationBarConfigure : NSObject

/**导航栏背景色，默认白色*/
@property (nonatomic, strong) UIColor *backgroundColor;
/**导航栏背景图片*/
@property (nonatomic, strong) UIImage *backgroundImage;
/**导航栏标题颜色，默认黑色*/
@property (nonatomic, strong) UIColor *titleColor;

/**导航栏标题字体，默认系统字体17*/
@property (nonatomic, strong) UIFont *titleFont;

/**返回按钮图片，默认nil，优先级高于backStyle*/
@property (nonatomic, strong) UIImage *backImage;
/** 设置导航栏分割线颜色 默认@"eeeeee" */
@property (nonatomic, strong) UIColor *navShadowColor;

/**返回按钮样式，默认TFYNavigationBarBackStyleBlack*/
@property (nonatomic, assign) TFYNavigationBarBackStyle backStyle;

/**是否禁止导航栏左右item调整间距，默认NO*/
@property (nonatomic, assign) BOOL      tfy_disableFixSpace;

/**导航栏左右按钮距屏幕左边间距，默认是15，可自行调整*/
@property (nonatomic, assign) CGFloat   tfy_navItemLeftSpace;

/**导航栏左右按钮距屏幕右边间距，默认是15，可自行调整*/
@property (nonatomic, assign) CGFloat   tfy_navItemRightSpace;

/**是否隐藏状态栏，默认NO*/
@property (nonatomic, assign) BOOL statusBarHidden;

/**状态栏类型，默认UIStatusBarStyleDefault*/
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**左滑push过渡临界值，默认0.3，大于此值完成push操作*/
@property (nonatomic, assign) CGFloat   tfy_pushTransitionCriticalValue;

/**右滑pop过渡临界值，默认0.5，大于此值完成pop操作*/
@property (nonatomic, assign) CGFloat   tfy_popTransitionCriticalValue;

/**以下属性需要设置导航栏转场缩放为YES 手机系统大于等于11.0，使用下面的值控制x、y轴的位移距离，默认（5，5）*/
@property (nonatomic, assign) CGFloat   tfy_translationX;
@property (nonatomic, assign) CGFloat   tfy_translationY;

/**手机系统小于11.0，使用下面的值控制x、y轴的缩放程度，默认（0.95，0.97）*/
@property (nonatomic, assign) CGFloat   tfy_scaleX;
@property (nonatomic, assign) CGFloat   tfy_scaleY;

/**调整导航栏间距时需要屏蔽的VC（默认nil），支持Class和NSString*/
@property (nonatomic, strong) NSArray *shiledItemSpaceVCs;

/**需要屏蔽手势处理的VC（默认nil），支持Class和NSString*/
@property (nonatomic, strong) NSArray *shiledGuestureVCs;

/**导航栏左右间距，内部使用*/
@property (nonatomic, assign, readonly) CGFloat navItemLeftSpace;
@property (nonatomic, assign, readonly) CGFloat navItemRightSpace;

/**单例，设置一次全局使用*/
+ (instancetype)sharedInstance;

/**统一配置导航栏外观，最好在AppDelegate中配置*/
- (void)setupDefaultConfigure;

/**设置自定义配置，此方法只需调用一次 配置回调*/
- (void)setupCustomConfigure:(void (^)(TFYNavigationBarConfigure *configure))block;

/**更新配置  配置回调*/
- (void)updateConfigure:(void (^)(TFYNavigationBarConfigure *configure))block;

/**获取APP当前最顶层的可见viewController*/
- (UIViewController *)visibleViewController;

/**判断是否是有缺口的屏幕（刘海屏）*/
- (BOOL)tfy_isNotchedScreen;

/**安全区域*/
- (UIEdgeInsets)tfy_safeAreaInsets;

/**状态栏frame*/
- (CGRect)tfy_statusBarFrame;

#pragma mark - 内部方法
/**获取当前item修复间距*/
- (CGFloat)tfy_fixedSpace;

@end

@interface UIViewController (Common)
- (UIViewController *)tfy_visibleViewVCfExist;
@end

NS_ASSUME_NONNULL_END
