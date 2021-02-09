//
//  UIScrollView+TFYCategory.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/11/3.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (TFYCategory)
// 禁止手势处理，默认为NO，设置为YES表示不对手势冲突进行处理
@property (nonatomic, assign) BOOL  tfy_disableGestureHandle;

@end

NS_ASSUME_NONNULL_END
