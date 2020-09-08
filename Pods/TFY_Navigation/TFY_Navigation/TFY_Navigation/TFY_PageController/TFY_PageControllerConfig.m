//
//  TFY_PageControllerConfig.m
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "TFY_PageControllerConfig.h"

@implementation TFY_PageControllerConfig
/**
 默认初始化方法
 */
+ (TFY_PageControllerConfig *)defaultConfig{
    TFY_PageControllerConfig *config = [[TFY_PageControllerConfig alloc] init];
    //标题-----------------------------------
    //默认未选中标题颜色 灰色
    config.titleNormalColor = [UIColor grayColor];
    //默认选中标题颜色 黑色
    config.titleSelectedColor = [UIColor blackColor];
    //默认未选中标题字体 18号系统字体
    config.titleNormalFont = [UIFont systemFontOfSize:18];
    //默认选中标题字体 18号粗体系统字体
    config.titleSelectedFont = [UIFont boldSystemFontOfSize:18];
    //默认标题间距 10
    config.titleSpace = 10;
    //默认过渡动画 打开
    config.titleColorTransition = true;
    
    //标题栏------------------------------------
    //默认标题栏缩进 左右各缩进10
    config.titleViewInset = UIEdgeInsetsMake(0, 10, 0, 10);
    //默认标题栏高度 40
    config.titleViewHeight = 40.0f;
    //默认标题栏背景颜色 透明
    config.titleViewBackgroundColor = [UIColor clearColor];
    //默认标题栏对齐方式 局左
    config.titleViewAlignment = TFY_PageTitleViewAlignmentLeft;
    
    //阴影--------------------------------------
    //默认显示阴影
    config.shadowLineHidden = false;
    //默认阴影宽度 30
    config.shadowLineWidth = 30.0f;
    //默认rightWidth
    config.rightWidth = 40.0f;
    //默认阴影高度 3
    config.shadowLineHeight = 3.0f;
    //默认阴影颜色 黑色
    config.shadowLineColor = [UIColor blackColor];
    //默认阴影动画 平移
    config.shadowLineAnimationType = TFY_PageShadowLineAnimationTypePan;
    //cell文字动画，默认 无
    config.celltextAnimationType = TFY_PageTitleCellAnimationTypeNone;
    //底部分割线-----------------------------------
    //默认显示分割线
    config.separatorLineHidden = false;
    //默认分割线颜色 浅灰色
    config.separatorLineColor = [UIColor lightGrayColor];
    //默认分割线高度 0.5
    config.separatorLineHeight = 0.5f;
    
    //分段式标题颜色------------------------------
    //默认分段式选择器颜色 黑色
    config.segmentedTintColor = [UIColor blackColor];
    //默认分段选择器颜色 lightTextColor
    config.segmentBackColor = UIColor.lightTextColor;
    //默认不随宽度
    config.segmentWidthsByContent = NO;
    //分段选择器默认选择 颜色 黑色
    config.segmentNormalColor = UIColor.blackColor;
    //分段选择器默认选中 颜色 浅色
    config.segmentSelectedColor = UIColor.lightTextColor;
    //分段选择器 默认 标准字体15
    config.segmentNormalFont = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    //分段选择器 选中字体 默认 标准粗体15
    config.segmentSelectedFont = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    //分段选择器 圆角 默认 5
    config.segmentCornerRadius = 5;
    //分段选择器 边框宽度 默认 1
    config.segmentBorderWidth = 1;
    //分段选择器  边框颜色 默认 黑色
    config.segmentBorderColor = UIColor.clearColor;
    return config;
}

@end
