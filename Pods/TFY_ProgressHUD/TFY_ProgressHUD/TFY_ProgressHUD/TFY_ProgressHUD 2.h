//
//  TFY_ProgressHUD.h
//  TFY_AutoLayoutModelTools
//
//  Created by 田风有 on 2019/5/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//  

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark ----------###############----------以下只使用于自定义View动画----------###############----------

typedef NS_ENUM(NSUInteger, TFY_PopupShowType) {
    TFY_PopupShowType_None,              //没有
    TFY_PopupShowType_FadeIn,            //淡入
    TFY_PopupShowType_GrowIn,            //成长
    TFY_PopupShowType_ShrinkIn,           //收缩
    TFY_PopupShowType_SlideInFromTop,     //从顶部，底部，左侧，右侧滑入
    TFY_PopupShowType_SlideInFromBottom,
    TFY_PopupShowType_SlideInFromLeft,
    TFY_PopupShowType_SlideInFromRight,
    TFY_PopupShowType_BounceIn,           //从顶部，底部，左侧，右侧，中心弹跳
    TFY_PopupShowType_BounceInFromTop,
    TFY_PopupShowType_BounceInFromBottom,
    TFY_PopupShowType_BounceInFromLeft,
    TFY_PopupShowType_BounceInFromRight
};

typedef NS_ENUM(NSUInteger, TFY_PopupDismissType) {
    TFY_PopupDismissType_None,
    TFY_PopupDismissType_FadeOut,
    TFY_PopupDismissType_GrowOut,
    TFY_PopupDismissType_ShrinkOut,
    TFY_PopupDismissType_SlideOutToTop,
    TFY_PopupDismissType_SlideOutToBottom,
    TFY_PopupDismissType_SlideOutToLeft,
    TFY_PopupDismissType_SlideOutToRight,
    TFY_PopupDismissType_BounceOut,
    TFY_PopupDismissType_BounceOutToTop,
    TFY_PopupDismissType_BounceOutToBottom,
    TFY_PopupDismissType_BounceOutToLeft,
    TFY_PopupDismissType_BounceOutToRight
};

//在水平方向上布置弹出窗口
typedef NS_ENUM(NSUInteger, TFY_PopupHorizontalLayout) {
    TFY_PopupHorizontalLayout_Custom,
    TFY_PopupHorizontalLayout_Left,
    TFY_PopupHorizontalLayout_LeftOfCenter,           //中心左侧
    TFY_PopupHorizontalLayout_Center,
    TFY_PopupHorizontalLayout_RightOfCenter,
    TFY_PopupHoricontalLayout_Right
};
//在垂直方向上布置弹出窗口
typedef NS_ENUM(NSUInteger, TFY_PopupVerticalLayout) {
    TFY_PopupVerticalLayout_Custom,
    TFY_PopupVerticalLayout_Top,
    TFY_PopupVerticalLayout_AboveCenter,              //中心偏上
    TFY_PopupVerticalLayout_Center,
    TFY_PopupVerticalLayout_BelowCenter,
    TFY_PopupVerticalLayout_Bottom
};

#pragma mark ----------###############----------以下只使用于弹出框交互----------###############----------

typedef NS_ENUM(NSUInteger, TFY_PopupMaskType) {
    //允许与底层视图交互
    TFY_PopupMaskType_None,
    //不允许与底层视图交互。
    TFY_PopupMaskType_Clear,
    //不允许与底层视图、背景进行交互。
    TFY_PopupMaskType_Dimmed
};

struct TFY_PopupLayout {
    TFY_PopupHorizontalLayout horizontal;
    TFY_PopupVerticalLayout vertical;
};

typedef struct TFY_PopupLayout TFY_PopupLayout;

extern TFY_PopupLayout TFY_PopupLayoutMake(TFY_PopupHorizontalLayout horizontal, TFY_PopupVerticalLayout vertical);

extern const TFY_PopupLayout TFY_PopupLayout_Center;


@interface TFY_ProgressHUD : UIView
//自定义视图
@property (nonatomic, strong) UIView *contentView;
//弹出动画
@property (nonatomic, assign) TFY_PopupShowType showType;
//消失动画
@property (nonatomic, assign) TFY_PopupDismissType dismissType;
//交互类型
@property (nonatomic, assign) TFY_PopupMaskType maskType;
//默认透明的0.5，通过这个属性可以调节
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;
//提示透明度
@property (nonatomic, assign) CGFloat toastMaskAlpha;
//动画出现时间默认0.15
@property (nonatomic, assign) CGFloat showInDuration;
//动画消失时间默认0.15
@property (nonatomic, assign) CGFloat dismissOutDuration;
//当背景被触摸时，弹出窗口会消失。
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;
//当内容视图被触摸时，弹出窗口会消失默认no
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;
//弹出框背景颜色
@property (nonatomic , strong)UIColor *backcolor;
//显示动画启动时回调。
@property (nonatomic, copy, nullable) void(^willStartShowingBlock)(void);
//显示动画完成启动时回调。
@property (nonatomic, copy, nullable) void(^didFinishShowingBlock)(void);
//显示动画将消失时回调。
@property (nonatomic, copy, nullable) void(^willStartDismissingBlock)(void);
//显示动画已经消失时回调。
@property (nonatomic, copy, nullable) void(^didFinishDismissingBlock)(void);


/**
 * 展示有加载圈的文字提示
 */
+ (void)showWithStatus:(NSString*)content;
+ (void)showWithAttributedContent:(NSAttributedString *)attributedString;
/**
 * 展示有加载圈 maskType 交互枚举类型
 */
+ (void)showWithStatus:(NSString*)content maskType:(TFY_PopupMaskType)maskType;
+ (void)showWithAttributedContent:(NSAttributedString *)attributedString MaskType:(TFY_PopupMaskType)maskType;
/**
 *  展示成功的状态  string 传字符串
 */
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  展示失败的状态 string 字符串
 */
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  展示提示信息  string 字符串
 */
+ (void)showPromptWithStatus:(NSString *)string;
+ (void)showPromptWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  只显示文本，没有任何多余的显示
 */
+ (void)showTextWithStatus:(NSString *)string;
+ (void)showTextWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 * 弹出一个自定义视图
 */
+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView;
/**
 * 弹出一个自定义视图 contentView 自定义视图  showType 弹出动画 dismissType 消失动画 maskType 交互类型 shouldDismissOnBackgroundTouch 当背景被触摸时，弹出窗口会消失 默认yes shouldDismissOnContentTouch 当内容视图被触摸时，弹出窗口会消失默认no
 */
+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView showType:(TFY_PopupShowType)showType dismissType:(TFY_PopupDismissType)dismissType maskType:(TFY_PopupMaskType)maskType;

/**关闭所有弹出框*/
+ (void)dismissAllPopups;
/**
 * 关闭提示框 (只对提示框有效)
 */
+ (void)dismiss;
/**
 * 关闭文本 (只对提示框有效)
 */
+ (void)dismissStatus:(NSString *)string;
/**
 * 关闭自定义对应View
 */
+ (void)dismissSuperPopupIn:(UIView *)view animated:(BOOL)animated;
/**
 * 自定义View 弹出
 */
- (void)show;
/**
 * 自定义弹出框适应横竖屏
 */
- (void)showWithLayout:(TFY_PopupLayout)layout;
/**
 *  自定义View 弹出时间
 */
- (void)showWithDuration:(NSTimeInterval)duration;
/**
 * 自定义弹出框适应横竖屏 启动时间
 */
- (void)showWithLayout:(TFY_PopupLayout)layout duration:(NSTimeInterval)duration;
/**
 * 自定义弹出框位置
 */
- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view;
/**
 * 自定义弹出框位置 时间
 */
- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view duration:(NSTimeInterval)duration;

/**
 * 取消所有提示 animated 是否需要动画
 */
- (void)dismissAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
