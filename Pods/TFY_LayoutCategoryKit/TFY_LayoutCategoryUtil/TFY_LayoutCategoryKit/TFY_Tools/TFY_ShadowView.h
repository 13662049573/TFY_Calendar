//
//  TFY_ShadowView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/1/29.
//  Copyright © 2021 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ShadowTypeSide) {
    ShadowSideTop       = 1 << 0,
    ShadowSideBottom    = 1 << 1,
    ShadowSideLeft      = 1 << 2,
    ShadowSideRight     = 1 << 3,
    ShadowSideAllSides  = ~0UL
};

@interface TFY_ShadowView : UIView

/**
 * 设置四周阴影: shaodwRadius:5  shadowColor:[UIColor colorWithWhite:0 alpha:0.3]
 */
- (void)shaodw;
/**
 * 设置垂直方向的阴影
 *
 * shadowRadius   阴影半径
 * shadowColor    阴影颜色
 * shadowOffset   阴影b偏移
 */
- (void)verticalShaodwRadius:(CGFloat)shadowRadius
                    shadowColor:(UIColor *)shadowColor
                   shadowOffset:(CGSize)shadowOffset;
/**
 * 设置水平方向的阴影
 *
 * shadowRadius   阴影半径
 * shadowColor    阴影颜色
 * shadowOffset   阴影b偏移
 */
- (void)horizontalShaodwRadius:(CGFloat)shadowRadius
                      shadowColor:(UIColor *)shadowColor
                     shadowOffset:(CGSize)shadowOffset;
/**
 * 设置阴影
 *
 * shadowRadius   阴影半径
 * shadowColor    阴影颜色
 * shadowOffset   阴影b偏移
 * shadowSide     阴影边
 */
- (void)shaodwRadius:(CGFloat)shadowRadius
            shadowColor:(UIColor *)shadowColor
           shadowOffset:(CGSize)shadowOffset
           byShadowSide:(ShadowTypeSide)shadowSide;

/**
 * 设置圆角（四周）
 *
 * cornerRadius   圆角半径
 */
- (void)cornerRadius:(CGFloat)cornerRadius;
/**
 * 设置圆角
 *
 * cornerRadius   圆角半径
 * corners        圆角边
 */
- (void)cornerRadius:(CGFloat)cornerRadius
      byRoundingCorners:(UIRectCorner)corners;


@end

NS_ASSUME_NONNULL_END
