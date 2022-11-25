//
//  TFY_IndexViewConfiguration.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/6/8.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern const NSUInteger TFY_IndexViewInvalidSection;
extern const NSInteger TFY_IndexViewSearchSection;

typedef NS_ENUM(NSUInteger, TFY_IndexViewStyle) {
    TFY_IndexViewStyleDefault = 0,    // 指向点
    TFY_IndexViewStyleCenterToast,    // 中心提示弹层
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_IndexViewConfiguration : NSObject

@property (nonatomic, assign, readonly) TFY_IndexViewStyle indexViewStyle;    // 索引提示风格

@property (nonatomic, strong) UIColor *indicatorBackgroundColor;            // 指示器背景颜色
@property (nonatomic, strong) UIColor *indicatorTextColor;                  // 指示器文字颜色
@property (nonatomic, strong) UIFont *indicatorTextFont;                    // 指示器文字字体
@property (nonatomic, assign) CGFloat indicatorHeight;                      // 指示器高度
@property (nonatomic, assign) CGFloat indicatorRightMargin;                 // 指示器距离右边屏幕距离（default有效）
@property (nonatomic, assign) CGFloat indicatorCornerRadius;                // 指示器圆角半径（centerToast有效）

@property (nonatomic, strong) UIColor *indexItemBackgroundColor;            // 索引元素背景颜色
@property (nonatomic, strong) UIColor *indexItemTextColor;                  // 索引元素文字颜色
@property (nonatomic, strong) UIColor *indexItemSelectedBackgroundColor;    // 索引元素选中时背景颜色
@property (nonatomic, strong) UIColor *indexItemSelectedTextColor;          // 索引元素选中时文字颜色
@property (nonatomic, assign) CGFloat indexItemHeight;                      // 索引元素高度
@property (nonatomic, assign) CGFloat indexItemRightMargin;                 // 索引元素距离右边屏幕距离
@property (nonatomic, assign) CGFloat indexItemsSpace;                      // 索引元素之间间隔距离

+ (instancetype)configuration;

+ (instancetype)configurationWithIndexViewStyle:(TFY_IndexViewStyle)indexViewStyle;

+ (instancetype)configurationWithIndexViewStyle:(TFY_IndexViewStyle)indexViewStyle
                       indicatorBackgroundColor:(UIColor *)indicatorBackgroundColor
                             indicatorTextColor:(UIColor *)indicatorTextColor
                              indicatorTextFont:(UIFont *)indicatorTextFont
                                indicatorHeight:(CGFloat)indicatorHeight
                           indicatorRightMargin:(CGFloat)indicatorRightMargin
                          indicatorCornerRadius:(CGFloat)indicatorCornerRadius
                       indexItemBackgroundColor:(UIColor *)indexItemBackgroundColor
                             indexItemTextColor:(UIColor *)indexItemTextColor
               indexItemSelectedBackgroundColor:(UIColor *)indexItemSelectedBackgroundColor
                     indexItemSelectedTextColor:(UIColor *)indexItemSelectedTextColor
                                indexItemHeight:(CGFloat)indexItemHeight
                           indexItemRightMargin:(CGFloat)indexItemRightMargin
                                indexItemsSpace:(CGFloat)indexItemsSpace;

@end

NS_ASSUME_NONNULL_END
