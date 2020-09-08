//
//  TFY_PageControllerConfig.h
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 标题栏样式
 Basic 基本样式
 Segmented 分段样式
 */
typedef NS_ENUM(NSInteger, TFY_PageTitleViewStyle) {
    TFY_PageTitleViewStyleBasic = 0,
    TFY_PageTitleViewStyleSegmented = 1
};

/**
 标题对齐，居左，居中，局右
 */
typedef NS_ENUM(NSInteger, TFY_PageTitleViewAlignment) {
    TFY_PageTitleViewAlignmentLeft = 0,
    TFY_PageTitleViewAlignmentCenter = 1,
    TFY_PageTitleViewAlignmentRight = 2,
};

/**
 文字垂直对齐，居中，居上，局下
 */
typedef NS_ENUM(NSInteger, TFY_PageTextVerticalAlignment) {
    TFY_PageTextVerticalAlignmentCenter = 0,
    TFY_PageTextVerticalAlignmentTop = 1,
    TFY_PageTextVerticalAlignmentBottom = 2,
};

/**
 阴影末端形状，圆角、直角
 */
typedef NS_ENUM(NSInteger, TFY_PageShadowLineCap) {
    TFY_PageShadowLineCapRound = 0,
    TFY_PageShadowLineCapSquare = 1,
};

/**
 阴影对齐
 */
typedef NS_ENUM(NSInteger, TFY_PageShadowLineAlignment) {
    TFY_PageShadowLineAlignmentBottom = 0,
    TFY_PageShadowLineAlignmentCenter = 1,
    TFY_PageShadowLineAlignmentTop = 2,
};


/**
 阴影动画类型，平移、缩放、无动画
 */
typedef NS_ENUM(NSInteger, TFY_PageShadowLineAnimationType) {
    TFY_PageShadowLineAnimationTypePan = 0,
    TFY_PageShadowLineAnimationTypeZoom = 1,
    TFY_PageShadowLineAnimationTypeNone = 2,
};

/**
 * Cell文字动画类行，缩放
 */
typedef NS_ENUM (NSInteger ,TFY_PageCelltextAnimationType) {
    TFY_PageTitleCellAnimationTypeNone = 0,
    TFY_PageTitleCellAnimationTypeZoom = 1,
    
};



NS_ASSUME_NONNULL_BEGIN

@interface TFY_PageControllerConfig : NSObject

/**
 默认初始化方法
 */
+ (TFY_PageControllerConfig *)defaultConfig;
/**
 标题正常颜色 默认 grayColor
 */
@property (nonatomic, strong) UIColor *titleNormalColor;

/**
 标题选中颜色 默认 blackColor
 */
@property (nonatomic, strong) UIColor *titleSelectedColor;

/**
 标题正常字体 默认 标准字体18
 */
@property (nonatomic, strong) UIFont *titleNormalFont;

/**
 标题选中字体 默认 标准粗体18
 */
@property (nonatomic, strong) UIFont *titleSelectedFont;

/**
 标题间距 默认 10
 */
@property (nonatomic, assign) CGFloat titleSpace;

/**
 标题宽度 默认 文字长度
 */
@property (nonatomic, assign) CGFloat titleWidth;
/**
 右侧View宽度 默认 标题栏高度
 */
@property (nonatomic, assign) CGFloat rightWidth;
/**
 标题颜色过渡开关 默认 开
 */
@property (nonatomic, assign) BOOL titleColorTransition;

/**
 文字垂直对齐 默认居中
 */
@property (nonatomic, assign) TFY_PageTextVerticalAlignment textVerticalAlignment;

/**
 标题栏高度 默认 40
 */
@property (nonatomic, assign) CGFloat titleViewHeight;

/**
 标题栏背景色 默认 透明
 */
@property (nonatomic, strong) UIColor *titleViewBackgroundColor;

/**
 标题栏内容缩进 默认 UIEdgeInsetsMake(0, 10, 0, 10)
 */
@property (nonatomic, assign) UIEdgeInsets titleViewInset;

/**
 标题栏显示位置 默认 TFY_PageTitleViewAlignmentLeft（只在标题总长度小于屏幕宽度时有效）
 */
@property (nonatomic, assign) TFY_PageTitleViewAlignment titleViewAlignment;

/**
 标题栏样式 默认 TFY_PageTitleViewStyleBasic
 */
@property (nonatomic, assign) TFY_PageTitleViewStyle titleViewStyle;

/**
 是否在NavigationBar上显示标题栏 默认NO
 */
@property (nonatomic, assign) BOOL showTitleInNavigationBar;

/**
 隐藏底部阴影 默认 NO
 */
@property (nonatomic, assign) BOOL shadowLineHidden;

/**
 阴影高度 默认 3.0f
 */
@property (nonatomic, assign) CGFloat shadowLineHeight;


/**
 阴影宽度 默认 30.0f
 */
@property (nonatomic, assign) CGFloat shadowLineWidth;

/**
 阴影颜色 默认 黑色
 */
@property (nonatomic, strong) UIColor *shadowLineColor;

/**
 阴影末端形状 默认 TFY_PageShadowLineCapRound
 */
@property (nonatomic, assign) TFY_PageShadowLineCap shadowLineCap;

/**
 默认动画效果 默认 TFY_PageShadowLineAnimationTypePan
 */
@property (nonatomic, assign) TFY_PageShadowLineAnimationType shadowLineAnimationType;

/**
 阴影对齐 默认XLPageShadowLineAlignmentBottom
 */
@property (nonatomic, assign) TFY_PageShadowLineAlignment shadowLineAlignment;
/**
 * cell文字动画类型
 */
@property (nonatomic, assign) TFY_PageCelltextAnimationType celltextAnimationType;
/**
 隐藏底部分割线 默认 NO
 */
@property (nonatomic, assign) BOOL separatorLineHidden;

/**
 底部分割线高度 默认 0.5
 */
@property (nonatomic, assign) CGFloat separatorLineHeight;

/**
 底部分割线颜色 默认 lightGrayColor
 */
@property (nonatomic, strong) UIColor *separatorLineColor;

/**
 分段选择器颜色 默认 黑色
 */
@property (nonatomic, strong) UIColor *segmentedTintColor;
/**
  分段选择器背景颜色 默认 lightTextColor
 */
@property (nonatomic, strong) UIColor *segmentBackColor;
/**
  是否根据选项中的内容自适应选项宽度 默认 NO
 */
@property (nonatomic, assign) BOOL segmentWidthsByContent;
/**
 分段选择器默认选择 颜色 黑色
 */
@property (nonatomic, strong) UIColor *segmentNormalColor;
/**
 分段选择器默认选中 颜色 浅色
 */
@property (nonatomic, strong) UIColor *segmentSelectedColor;
/**
  分段选择器 默认 标准字体15
 */
@property (nonatomic, strong) UIFont *segmentNormalFont;

/**
 分段选择器 选中字体 默认 标准粗体15
 */
@property (nonatomic, strong) UIFont *segmentSelectedFont;
/**
   分段选择器 圆角 默认 5
 */
@property (nonatomic, assign) CGFloat segmentCornerRadius;
/**
   分段选择器 边框宽度 默认 1
 */
@property (nonatomic, assign) CGFloat segmentBorderWidth;
/**
   分段选择器  边框颜色 默认 透明
 */
@property (nonatomic, strong) UIColor *segmentBorderColor;
@end

NS_ASSUME_NONNULL_END
