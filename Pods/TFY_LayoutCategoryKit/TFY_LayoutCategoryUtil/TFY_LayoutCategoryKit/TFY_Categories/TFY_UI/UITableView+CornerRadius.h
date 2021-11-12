//
//  UITableView+CornerRadius.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/3/2.
//  Copyright © 2021 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, TFY_TableViewCornerRadiusStyle) {
    /**
     *  没有cornerRadius效应
     */
    TableViewCornerRadiusStyleNone = 0,
    /**
     *  使角半径效应到每个单元格
     */
    TableViewCornerRadiusStyleEveryCell = 1,
    /**
     *  使角半径效果只对一个部分的第一个和最后一个单元格
     */
    TableViewCornerRadiusStyleSectionTopAndBottom = 2,
};

@interface UITableView (CornerRadius)
/**
 *  如果启用角半径效应，默认值为NO
 */
@property (nonatomic, assign) BOOL tfy_enableCornerRadiusCell;

/**
 *  角半径效应值
 */
@property (nonatomic, assign) CGFloat tfy_cornerRadius;

/**
 *  边角半径的内页
 */
@property (nonatomic, assign) UIEdgeInsets tfy_cornerRadiusMaskInsets;

/**
 *  ><
 */
@property (nonatomic, assign) TFY_TableViewCornerRadiusStyle tfy_cornerRadiusStyle;
@end

@interface UIView (Radius)

/**
 *  添加圆角
 */
- (void)tfy_addRectCorner:(UIRectCorner)corners radius:(CGFloat)radius;

/**
 *  添加圆角以及缩进
 */

- (void)tfy_addRectCorner:(UIRectCorner)corners radius:(CGFloat)radius insets:(UIEdgeInsets)inserts;

/**
 *  移除圆化效果
 */
- (void)tfy_removeCornerRadius;

/**
 *  如果子类没有重写则为sel
 */
- (UIView *)tfy_viewForMakeCornerRadius;

@end

NS_ASSUME_NONNULL_END
