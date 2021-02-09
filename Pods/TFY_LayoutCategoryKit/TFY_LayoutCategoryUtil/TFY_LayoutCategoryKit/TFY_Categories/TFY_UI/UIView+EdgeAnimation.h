//
//  UIView+EdgeAnimation.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/1/30.
//  Copyright © 2021 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (EdgeAnimation)<CAAnimationDelegate>

//边缘涂成填充颜色  默认: GrayColor
@property (nonatomic, strong) UIColor *tfy_edgeFillColor;
//添加边缘效果
- (void)tfy_addEdgeEffect;

@end

NS_ASSUME_NONNULL_END
