//
//  TFY_BadgeControl.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/12/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BadgeViewFlexMode) {
    BadgeViewFlexModeHead,    // 左伸缩 Head Flex    : <==●
    BadgeViewFlexModeTail,    // 右伸缩 Tail Flex    : ●==>
    BadgeViewFlexModeMiddle   // 左右伸缩 Middle Flex : <=●=>
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BadgeControl : UIControl

+ (instancetype)defaultBadge;

/**
 设置文本
 */
@property (nullable, nonatomic, copy) NSString *text;

/**
 设置副本文案
 */
@property (nullable, nonatomic, strong) NSAttributedString *attributedText;

/**
  设置字体大小
 */
@property (nonatomic, strong) UIFont *font;

/**
 设置背景图像
 */
@property (nullable, nonatomic, strong) UIImage *backgroundImage;
/**
 Badge伸缩的方向
 */
@property (nonatomic, assign) BadgeViewFlexMode flexMode;

/**
 记录Badge的偏移量
 */
@property (nonatomic, assign) CGPoint offset;
@end

NS_ASSUME_NONNULL_END
